
function Get-StaticProperty {
    <#
    .synopsis
        **only** fetches psobject.properties. Helper function for that specific case
    .description
        sort of an internal func, sort of not.
    .example
        PS> ls . -Dir | Get-StaticProperty
    #>
    [cmdletbinding()]
    [alias('StaticMemberProp')]
    param(
        # NoColor
        [Parameter()][switch]$NoColor,

        # inputobject
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        $target = $InputObject
        $propNames = $target | Fm -MemberType Property -Force | ForEach-Object Name
        $strNull = "[`u{2400}]"
        if (!$NoColor) {
            $strNull = $strNull | New-Text -fg 'gray30'
        }
        $propNames | ForEach-Object {
            $propName = $_
            $propVal = $target.$propName
            if ($null -eq $propVal) {
                $typeName = $strNull
            }
            else {
                $typeName = $propVal.GetType() | Format-TypeName
            }
            [pscustomobject]@{
                TypeName = $typeName ?? '?'
                Name     = $propName
                Value    = $propVal ?? $strNull
                # ValMem = $target::$Prop ?? $strNull # Maybe redundant, at least for properties
            }
        }
    }
}