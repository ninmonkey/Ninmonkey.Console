function Get-ObjectProperty {
    <#
    .synopsis
        Nicer output to inspect objects than ($obj.psobject.properties | format-table)
    .example
    PS> [pscustomobject]@{ 'species'='cat'; 'lives'=9;} | Get-ObjectProperty | Format-Table

        Type     TypeOfInstance Name    Value
        ----     -------------- ----    -----
        [String] [String]       species cat
        [Int32]  [Int32]        lives   9

    .example
    PS> [pscustomobject]@{ 'species'='cat'; 'lives'=9;} | Get-ObjectProperty | Format-List

        Type           : [String]
        TypeOfInstance : [String]
        Name           : species
        Value          : cat

        Type           : [Int32]
        TypeOfInstance : [Int32]
        Name           : lives
        Value          : 9

    .example
    PS> [xml]'<Item name="" identifier="spear" category="Equipment" interactthroughwalls="true" cargocontaineridentifier="metalcrate" tags="mediumitem,harpoonammo" Scale="0.5" impactsoundtag="impact_metal_light"></Item>'
            | Get-ObjectProperty
            | ? Name -in 'NextSibling', 'PreviousSibling', 'identifier'

    #output:
        Type      TypeOfInstance Name            Value
        ----      -------------- ----            -----
        [String]  [String]       LocalName       #document
        [XmlNode] [␀]            PreviousSibling
        [XmlNode] [␀]            NextSibling

    #>
    [cmdletbinding()]
    [Alias('Prop', 'ObjectProperty')]
    param(

        # any object with properties to inspect
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject,

        # Return extra informaiton?
        [Parameter()][switch]$Detailed
    )

    begin {
        $splat_FormatType = @{
            IgnorePrefix = 'System.Xml'
            # NoBrackets   = $false
        }

        $Config = @{
            SymbolNull = "[`u{2400}]" # [Null]
        }
    }
    process {
        $InputObject.psobject.properties | ForEach-Object {
            $prop = $_
            $prop | Format-Table | Out-String | Write-Debug

            $ValueIsNull = $null -eq $prop.Value
            if ($ValueIsNull) {
                $DisplayedValueType = $Config.SymbolNull
            } else {
                $DisplayedValueType = $prop.Value.GetType()  | Format-TypeName @splat_FormatType
            }

            $meta = [ordered]@{
                Type           = $prop.TypeNameOfValue | Format-TypeName @splat_FormatType
                TypeOfInstance = $DisplayedValueType
                Name           = $prop.Name
                Value          = $prop.Value
            }
            [pscustomobject]$meta
            # $x + 3
            # hr | Write-Warning
            # $prop.TypeNameOfValue -as 'type' | Format-TypeName
            # | Write-Warning
            # $prop.TypeNameOfValue -as 'type'
            # | Write-Warning
        }
    }
    end {
        Write-Warning 'should not be a raw table'
    }

}

if ($false) {
    $gcm = Get-Command Select-Object
    $gcm.Parameters | Prop | Format-Table
}

if ($false) {
    $catHash = @{'a' = 'cat'; age = 9; children = (0..4) }
    $catObj = [pscustomobject]$catHash

    Label 'hash'
    $catHash | Prop # Get-ObjectProperty

    Label 'Obj'
    $catObj | Prop # Get-ObjectProperty
    hr

    $gcm = Get-Command Select-Object
    $gcm.Parameters | Prop | Format-List
    $gcm.Parameters | Prop | Format-Table
    $prop = $gcm.psobject.properties | Where-Object  Name -EQ Parameters # | % TypeNameOfValue
    $prop.TypeNameOfValue -as 'type' | Format-TypeName
}