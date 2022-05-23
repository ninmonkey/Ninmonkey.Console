using namespace System.Management.Automation

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Test-JsonifyPropertyIsOk'
    )
    $publicToExport.alias += @(
        '_propertyIsGood' # 'Test-JsonifyPropertyIsOk'
    )
}

class SerialTestResult {
    [string]$Name = [string]::Empty
    [bool]$IsLong = $false # Longer than your invoked limit
    [bool]$HasJsonWarning = $false # Was a Warning Json Depth thrown ?
    hidden [string]$Json
    [int]$JsonLength = 0
    [PSPropertyInfo]$Instance = $null # was [object]

}

function Test-JsonifyPropertyIsOk {
    <#
    .synopsis
        test whether an arbitrary property is "safe" to Jsonify, or does it require more
    .DESCRIPTION
        It returns a [SerialTestResult] per property
        property was intially hidden for CLI spam -- instead hide it with property sets

        Detects if objects require X depth,
    .notes
        for context currently "is good":
            [RgbColor]'red' | Jsonify | to->Json

        currently "is bad": (for type names)
            [RgbColor] | Jsonify | to->Json

    .example
        ([RgbColor]).psobject.properties | Test-JsonifyPropertyIsOk | Ft
    .example
        $props = (Get-Module)[0].psobject.properties
        $props | _propertyIsGood
    #>
    [alias('_propertyIsGood')]
    param(
        # Input from a piped property, $x.psobject.property
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [PSPropertyInfo]
        $Property,

        [int]$RenderMaxLength = 180
    )
    process {
        [string]$render = $_.Value
        | ConvertTo-Json -wa ignore -ea ignore -Compress #| ? Length -lt $RenderMaxLength

        $test = [SerialTestResult]@{
            Name           = $Property.Name
            JsonLength     = $render.Length
            Json           = $render
            IsLong         = $render.Length -gt $RenderMaxLength
            Instance       = $Property
            HasJsonWarning = $false
        }

        try {
            $testWarning = $Property.Value
            | ConvertTo-Json -Compress -WA Stop -ea stop
        } catch {
            $test.HasJsonWarning = $true
        }

        return $test
    }
}
