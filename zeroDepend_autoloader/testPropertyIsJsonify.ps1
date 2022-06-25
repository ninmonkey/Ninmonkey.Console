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
    # hidden [string]$Json
    [string]$Json
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
        $resp = [rgbcolor].psobject.properties
        | Test-JsonifyPropertyIsOk -Options @{ 'JsonMaxDepth' = 1 ; }
    .example
        ([RgbColor]).psobject.properties | Test-JsonifyPropertyIsOk | Ft
    .example
        $props = (Get-Module)[0].psobject.properties
        $props | _propertyIsGood
    .EXAMPLE
        $resp | sort JsonLength | ? JsonLength -gt 100
        $resp | sort JsonLength | ? JsonLength -gt 100
        | ft -AutoSize

            Name                  IsLong HasJsonWarning JsonLength Instance
            ----                  ------ -------------- ---------- --------
            DisplayString           True          False        261 System.String DisplayString{get=GetDis
            StructLayoutAttribute   True           True       3058 System.Runtime.InteropServices.StructL
            DeclaredFields          True           True       4851 System.Collections.Generic.IEnumerable
            DeclaredProperties      True           True       6567 System.Collections.Generic.IEnumerable
            ImplementedInterfaces   True           True       8082 System.Collections.Generic.IEnumerable
            Module                  True           True       8392 System.Reflection.Module Module {get;}
            Assembly                True           True      10591 System.Reflection.Assembly Assembly {g
            BaseType                True           True      18994 type BaseType {get;}
            DeclaredConstructors    True           True      20793 System.Collections.Generic.IEnumerable
            UnderlyingSystemType    True           True      32063 type UnderlyingSystemType {get;}
            DeclaredMethods         True           True      60645 System.Collections.Generic.IEnumerable
            DeclaredMembers         True           True      92853 System.Collections.Generic.IEnumerable
    #>
    [alias('_propertyIsGood')]
    param(
        # Input from a piped property, $x.psobject.property
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [PSPropertyInfo]
        $Property,

        [int]$RenderMaxLength = 180,
        [hashtable]$Options = @{}
    )
    begin {
        $Config = Join-Hashtable -BaseHash @{
            JsonMaxDepth = 3
        } -OtherHash $Options
    }
    process {
        [string]$render = $_.Value
        | ConvertTo-Json -wa ignore -ea ignore -Compress -Depth $Config.JsonMaxDepth  #| ? Length -lt $RenderMaxLength

        $test = [SerialTestResult]@{
            Name           = $Property.Name
            JsonLength     = $render.Length
            Json           = $render
            IsLong         = $render.Length -gt $RenderMaxLength
            Instance       = $Property
            HasJsonWarning = $false
        }

        # try {
        $testWarning = $Property.Value
        | ConvertTo-Json -Compress -WA 'continue' -WarningVariable 'warnvar' -Depth $Config.JsonMaxDepth 3>$null
        # maybe also capture after commmand
        $test.HasJsonWarning = $warnvar.count -gt 0
        # } catch {
        #     $test.HasJsonWarning = $true
        # }

        return $test
    }
}
