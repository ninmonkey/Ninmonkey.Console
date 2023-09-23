#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Format-Join.Csv' # 'Format-Join.Csv' = { 'Join.Csv' }
    )
    $publicToExport.alias += @(
        'Join.Csv' # 'Format-Join.Csv' = { 'Join.Csv' }
    )
}


function Format-Join.Csv {
    <#
    .SYNOPSIS
        common Csv patterns
        fairly powerfull
    .example
        PS> 12..5 |Join.Csv -JoinDelimString ' ' -Options @{ SingleQuote = $false }
    .example
        PS> 12..5 |Join.Csv -JoinDelimString "`n- " -Options @{ SingleQuote = $false ; DoubleQuote = $true }

    .notes
        render-* implies ansi colors

    .link
        Ninmonkey.Console\Format-Join.Csv
    .link
        Ninmonkey.Console\Format-UnorderedList
    #>
    [Alias(
        'Join.Csv'
    )]
    param(
        # list of objects/strings to add
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [AllowNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$InputObject,

        # todo: Make custom arg completer
        # with parameter, so I can say 'use set X'
        # like 'arrows', or 'bars', or 'checkbox'
        [ArgumentCompletions(
            "','",
            "', '",
            '•', '-', '⦿', '‣', '•', '⁃', '⁌', '◦'
        )]
        # sets bullet types, but if overriden in -Options, Options has priority
        [string]$JoinDelimString = ', ',
#         [ArgumentCompletions(
#             '@{ ULHeader = (hr 0) ; ULFooter  = (hr 0); }',
# @'
# @{ ULHeader =  @( (hr 1) ; Label "Newest Files" "c:/temp"  ) | Join-String ; ULFooter  = (hr 0); }
# '@, #-replace '\r?', '',
# # @'
# # @{  todo: Can I use the -replace operator, acting as a const expression?
# #     ULHeader =  @( (hr 1) ; Label "Newest Files" "c:/temp"  ) | Join-String
# #     ULFooter  = (hr 0);
# # }
# # '@, #-replace '\r?', '',
#             '@{ BulletStr = "•" }'
#         )]
        # sort output? assume sorting is alpha sort
        [switch]$Sorted,
        # make distinctt?
        [switch]$Unique,
        [hashtable]$Options = @{}
    )
    begin {
        $Config = mergeHashtable -OtherHash $Options -BaseHash @{
            SingleQuote    = $true
            DoubleQuote   = $false
            Separator = "`n"
            Prefix     = ''
            Suffix     = ''
            # FormatString = $Null
            Sort = $true
            Distinct = $True
        }
        [Collections.Generic.List[Object]]$Items = @()
        if($PSBoundParameters.containsKey('JoinDelimString')) {
            $Config.Separator = $JoinDelimString
        }
        if($PSCmdlet.MyInvocation.InvocationName -eq 'Join.Csv') {
            $Config.Separator = $JoinDelimString
        }
    }
    process {
        $items.AddRange(
            @( $InputObject )
        )
        # foreach ($str in $InputObject) { }

    }
    end {
        if($Sorted) {
            $sort_s = @{}
            if($Distinct) {
                $sort_s.unique = $true
            }
            $items = $items | Sort-Object @sort_s
        }

        $joinStr_s = @{}
        if($Config.SingleQuote) {
            $joinStr_s.SingleQuote = $true
        }
        if($Config.DoubleQuote) {
            $joinStr_s.DoubleQuote = $true
        }
        if(-not ($null -eq $Config.Separator) ) {
            $joinStr_s.separator = $Config.Separator
        }
        if($Config.ContainsKey('Prefix')) {
            $JoinStr_s.OutputPrefix = $Config.OutputPrefix
        }
        if($Config.ContainsKey('Suffix')) {
            $JoinStr_s.OutputSuffix = $Config.OutputSuffix
        }
        if($Config.ContainsKey('Separator')) {
            $JoinStr_s.Separator = $Config.Separator
        }
        if($Config.ContainsKey('Separator')) {
            $JoinStr_s.Separator = $Config.Separator
        }

        $joinStr_s |Json -depth 0 | Join-string -op 'Format-Join.Csv' | Write-Debug
        $Items | Join-String @joinStr_s
        <#
        Tip: Join-String gracefully handles empty types, gracefully.
        $null values are not passed as input

        #>
        # was

        # $joinStringSplat = @{
        #     Separator    = "`n $StrBullet "
        #     OutputPrefix = "`n $StrBullet "
        #     OutputSuffix = "`n"
        # }
        # $joinStringSplat = @{
        #     # -sep and prefix are normally the same
        #     Separator    = '{0}{1}{2}{1}' -f @( # "`n $StrBullet "
        #         $Config.BulletPrefix
        #         $Config.PaddingStr
        #         $Config.BulletStr
        #     )
        #     OutputPrefix = '{0}{1}{2}{1}' -f @( # "`n $StrBullet "
        #         $Config.BulletPrefix
        #         $Config.PaddingStr
        #         $Config.BulletStr
        #     )
        #     OutputSuffix = $Config.BulletPrefix
        # }

        # $Items
        # | Join-String @joinStringSplat
        # | Join-String -op $COnfig.ULHeader -os $Config.ULFooter


        # original:
        # $Items | Join-String -sep "`n $StrBullet " -op "`n $StrBullet " -os "`n"
    }
}
