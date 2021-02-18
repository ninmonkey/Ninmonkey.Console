
function ConvertTo-HexString {
    <#
    .synopsis
    convert [int] into '0xff' or 'ff f3' hex strings
    .notes
    originally based on 'SeeminglyScience\ConvertTo-HexString'
    #>
    [Alias('Hex')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline)]
        [psobject[]] $InputObject,

        [Parameter(Position = 0)]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('Padding')]
        [int] $ZeroPadding,

        # NoPrefix as '0x'
        [Parameter()][switch]$NoPrefix
    )
    process {
        foreach ($currentItem in $InputObject) {
            $numeric = Number $currentItem

            # difference between using $padding as non null?
            # PSBoundParameters means ignoring PSDefaultValues ?

            if ($PSBoundParameters.ContainsKey((nameof { $Padding }))) {
                "0x{0:x$ZeroPadding}" -f $numeric
                continue
            }

            '0x{0:x}' -f $numeric
        }
    }
}