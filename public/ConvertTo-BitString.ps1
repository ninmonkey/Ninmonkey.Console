function ConvertTo-BitString {
    <#
    .synopsis
    originally from: <ConvertTo-SciBitString>
    .notes
        currently the same, separate same. separate for dependency clarity
    .example
        PS> 0..3 | bits | Join-String -sep ' '

            0000.0000 0000.0001 0000.0010 0000.0011
    .example
        # For more see:
            <./test/public/ConvertTo-BitString.tests.ps1>
    #>
    [Alias('Bits')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline)]
        [psobject[]] $InputObject,

        [Parameter(Position = 0)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Padding,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [AllowEmptyString()]
        [string] $ByteSeparator = ' ',

        [Parameter(Position = 2)]
        [ValidateNotNull()]
        [AllowEmptyString()]
        [string] $HalfByteSeparator = '.'
    )
    begin {
        function GetBinaryString([psobject] $item) {
            $numeric = Number $item
            if ($null -eq $numeric) {
                return
            }

            $bits = [convert]::ToString($numeric, <# toBase: #> 2)
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey((nameof { $Padding }))) {
                $padAmount = $Padding * 8
                if ($padAmount -ge $bits.Length) {
                    return $bits.PadLeft($Padding * 8, [char]'0')
                }
            }

            $padAmount = 8 - ($bits.Length % 8)
            if ($padAmount -eq 8) {
                return $bits
            }

            return $bits.PadLeft($padAmount + $bits.Length, [char]'0')
        }
    }
    process {
        foreach ($currentItem in $InputObject) {
            $binaryString = GetBinaryString $currentItem

            # yield
            $binaryString -replace
            '[01]{8}(?=.)', "`$0$ByteSeparator" -replace
            '[01]{4}(?=[01])', "`$0$HalfByteSeparator"
        }
    }
}
