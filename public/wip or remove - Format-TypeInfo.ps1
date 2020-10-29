using namespace System.Reflection

function _Remove-TypeInfoNamespace {
    param (

        [Parameter(
            Mandatory, ValueFromPipeline,
            HelpMessage = 'string from a type info')]
        [string]$TypeInfoString,

        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'prefix list'
        )]
        [string[]]$StripNamespace
    )

    begin {
        $regex = @{}
        $DefaultNamespaces = 'System', 'System.Automation', 'System.Reflection', 'System.Collections.Generic'

        if ($null -eq $StripNamespace) {
            $StripNamespace = $DefaultNamespaces
        }

        $regex.StripNamespaces = $StripNamespace | ForEach-Object {
            '^' + [regex]::Escape( "$_." )
        } | Join-String -Separator '|'

        Write-Debug "Regex: $($regex.StripNamespaces)"
    }
    process {

        # TypeInfo

        $TypeInfoString -replace $regex.StripNamespaces, ''
    }

}

"sdfds".gettype() | _Remove-TypeInfoNamespace -Debug
"sdfds".GetType().FullName | _Remove-TypeInfoNamespace  -Verbose -Debug
function Format-TypeInfo {
    param(
        [Parameter(Mandatory, ValueFromPipeline,
            HelpMessage = 'Object or [TypeInfo]')]
        [object]$InputObject,

        [Parameter(
            Position = 0, HelpMessage = 'Output display mode'
        )]
        [ValidateSet('TruncateList')]
        [string]$OutputMode
    )
    begin {

        $StripNamespaces = 'System', 'System.Automation', 'System.Reflection', 'System.Collections.Generic'
        [TypeInfo]$InputTypeInfo
    }

    process {
        if (! ( $InputObject -is [TypeInfo] )) {
            $InputTypeInfo = $InputObject.GetType()
        } else {
            $InputTypeInfo = $InputObject
        }
        <#
        todo: parse and cleanup nested type names
        [1] strip assembly fully qualified names
        [2] strip commmon prefix
            Assembly : System.Private.CoreLib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e
            AssemblyQualifiedName : System.Collections.Hashtable, System.Private.CoreLib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e
            Attributes : AutoLayout, AnsiClass, Class, Public, Serializable, BeforeFieldInit
            BaseType : System.Object
            ContainsGenericParameters : False
            CustomAttributes : System.Collections.ObjectModel.ReadOnlyCollection`1[System.Reflection.CustomAttributeData]
            DeclaredConstructors : System.Reflection.ConstructorInfo[]
            DeclaredEvents : System.Reflection.EventInfo[]
        #>

        if ($OutputMode -eq 'TruncateList') {
            $InputObject | Format-Pair
            return
        }

        $hash = [ordered]@{
            TypeName            = $InputTypeInfo.Name
            TypeFullName        = $InputTypeInfo.FullName
            TypeFullNameAbbr    = $InputTypeInfo.FullName  | _Remove-TypeInfoNamespace
            InputValue_Instance = $InputObject
            TypeInfo_Instance   = $InputTypeInfo
        }
        [pscustomobject]$hash

    }
}

# input sample
$sample1 = ( @{a = 2 } ).gettype()
$sample2 = @( @{cat = 7 } ).gettype()
$sample3 = @{name = 'Frank' }
$sample4 = [pscustomobject]@{
    animal = @{
        species = 'cat'
        lives   = 9
    }
}
$all = $sample1, $sample2, $sample3, @( 1, @('z', 'e')), $sample4, 'Text'
h1 'initial values without processing'
$all




if ($false -and 'slow') {
    $sample1 | Format-TypeInfo TruncateList
    $all[0..2] | Format-TypeInfo TruncateList
}
if ($false -and 'slow2') {

    h1 'test1'
    23 | Format-TypeInfo | Format-Table
    @(91) | Format-TypeInfo | Format-Table

    23 | Format-TypeInfo | Format-List
    @(91) | Format-TypeInfo | Format-List

}