
function ConvertTo-Number {
    <#
    .synopsis
    originally from: <ConvertTo-SciNumber>
    .notes
        currently the same, separate same. separate for dependency clarity
    .example|
        # For more see:
            <./test/public/ConvertTo-Number.ps1>
    #>
    [Alias('Number')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline, Position = 0)]
        [psobject] $InputObject
    )
    process {
        foreach ($currentItem in $InputObject) {
            if ($currentItem -is [Enum]) {
                # yield
                $currentItem.value__
                continue
            }

            # see: <https://docs.microsoft.com/en-us/dotnet/api/System.ValueType?view=net-5.0#remarks>
            if ($currentItem -isnot [ValueType]) {
                # yield
                $currentItem -as [int]
                continue
            }

            if ([array]::IndexOf($script:WellKnownNumericTypes, $currentItem.GetType()) -eq -1) {
                # yield
                $currentItem -as [int]
                continue
            }

            # yield
            $currentItem
        }
    }
}
