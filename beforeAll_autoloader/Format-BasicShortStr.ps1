if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'Format-ShortString'
    )
    $script:publicToExport.alias += @(
        'shortStr'  # 'Format-ShortString'

    )
}

function Format-ShortString {
    <#
    .SYNOPSIS
        ensure text never goes over the expected limits, shorten if they do
    .notes

        see also: Format-WrapText
            if you want to preserve text. this function truncates it.

        I was expecting it to 'break' by included ranges when they overlap
        like 0..4 => [1.2.3.4...3.4.5]

        not performant at all

        future:
        - [ ] use spans ?
        - [ ] pad if string is not long enough, at least (tailCount + headCount) in length
        - [ ] string is long enough, then do not add $Separator to it
        - [ ] use StringBuilder
        - [ ] format control chars

        - [ ] make [ArgumentCompletions] abbreviate the names on selection, but completes to full code

    .EXAMPLE
        PS> ps | s -First 20 | Join-String -sep (hr 1) -Property {
                $_.CommandLine | shortStr -HeadCount 90 -TailCount 40 }
    .EXAMPLE
        PS> 'z'..'a' -join '_'
            'z'..'a' -join '_' | shortStr
            'z'..'a' -join '_' | shortStr -HeadCount 3 -TailCount 3 -Options @{ AlwaysQuoteInner = $false}
            'z'..'a' -join '_' | shortStr -HeadCount 3 -TailCount 3 -Options @{ AlwaysQuoteInner = $true}

        # output
            z_y_x_w_v_u_t_s_r_q_p_o_n_m_l_k_j_i_h_g_f_e_d_c_b_a
            ["z_y_x_w_v_u_t_s_r_q_"..."_e_d_c_b_a"]
            [z_y...b_a]
            ["z_y"..."b_a"]
    .link
        Ninmonkey.Console\Format-ShortString
    .link
        Ninmonkey.Console\Format-WrapText
    #>
    [Alias(
        'shortStr'
        # 'str->short'  # ??
    )]
    [CmdletBinding()]
    [OutputType('System.String')]
    param(
        [Alias('Text', 'InputText')]
        [AllowNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$InputObject,

        # String Length of chars/columns. Note this is not codepoints
        [Alias('MaxLength')]
        [Parameter()]
        [int]$Length = 80,

        # Number of [Char]s, the String.Length property. Future could add codepoints support
        [int]$HeadCount = 120,
        # Number of [Chars]s, the String.Length property
        [int]$TailCount = 30,

        # pad with blanks if this is set
        [int]$MinLength = 0,

#         [ArgumentCompletions(
#             '@{ AlwaysQuoteInner = $true}',
#             '@{ Separator = '' | '' ; TotalPrefix = ''<''; TotalSuffix = ''>''; AlwaysJoinNewlines = $false; AlwaysQuoteInner = $true}',
#             '@{
#     AlwaysQuoteInner = $False ;
#     TotalPrefix      = $Color.Fg;
#     TotalSuffix      = $Color.Reset;
#     Separator        = @(
#         $Color.Reset
#         $Color.FgDim
#         ''...''
#         $Color.Reset
#         $Color.Fg
#     ) -join ''''
# }'
#         )]
        [hashtable]$Options = @{}
    )
    begin {
        if($MinLength -ne 0) { throw "MinLength NYI"}
        if($PSBoundParameters.ContainsKey('HeadCount')) { throw "HeadCount NYI"}
        if($PSBoundParameters.ContainsKey('TailCount')) { throw "TailCount NYI"}
        $Config = @{
            UsingNullSymbol = $true
            FormatControlChar = $true
            # Separator          = '…' # '..'
            # TotalPrefix        = '' # '['
            # TotalSuffix        = '' # ']'
            # AlwaysJoinNewlines = $true
            # AlwaysQuoteInner   = $false
        }
        $Config = Ninmonkey.Console\Join-Hashtable -OtherHash $Options -BaseHash $Config
    }
    process {
        if ($Null -eq $InputText) {
            if($Config.UsingNullSymbol) {
                return "`u{2400}"
            }
            return ''
        }
        $accum = if($Config.FormatControlChar) {
            $InputText | Format-ControlChar
        } else {
            $InputText
        }

        $originalLen = $accum.Length
        $wantedLen = $Length
        if($wantedLen -gt $originalLen) {
            $actualLen = $originalLen
        } else {
            $actualLen = $WantedLen
        }
        $finalStr = $accum.SubString(0, $ActualLen ) <# Substring(int startIndex, int length); #>

        return $finalStr


        # if ($Config.AlwaysJoinNewlines) {
        #     $Chars = $chars -join "`n"
        # }
        # $chars = $InputText.GetEnumerator()
        # $joinOuterStr = @{
        #     Separator    = $Config.Separator
        #     OutputPrefix = $Config.TotalPrefix
        #     OutputSuffix = $Config.TotalSuffix
        # }
        # if ( $Config.AlwaysQuoteInner) {
        #     $joinOuterStr['DoubleQuote'] = $true
        # }

        # $allowedLen = [Math]::Min( $OriginalLen, $WantLen)
        # # if ($InputText.Length -lt ($HeadCount.length + $TailCount.length )) {
        # #     # wasn't quite working
        # #     $joinOuterStr['Separator'] = ''
        # #     $Config['Separator'] = ''
        # # }
        # if ($Chars.Length -gt ($headCount + $TailCount)) {
        #     return $chars
        # }

        # 'abcd'.substring(0, $TotalLen  )

        # @(
        #     $chars | Select-Object -First $HeadCount | Join-String -sep ''
        #     $chars | Select-Object -Last $TailCount | Join-String -sep ''
        # ) | Join-String @joinOuterStr

    }

}

