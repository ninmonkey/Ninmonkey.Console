using namespace System.Collections.Generic

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

    .notes
        now defaults to one output per typename

    nyi: Currently does not find '$object.NoteProperty'

    example output:
        # example output:

        PS> ps | prop | ft

            TypeOfInstance Name                 Value
            -------------- ----                 -----
                    String Name                 Agent
                    Int32 SI                   0
                    Int32 Handles              495
                    Int64 VM                   176238592
                    Int64 WS                   16920576
                    Int64 PM                   41918464
                    Int64 NPM                  77528
                        [␀] Path
                        [␀] CommandLine
                        [␀] Parent
                        [␀] Company
                        [␀] CPU
                        [␀] FileVersion
                        [␀] ProductVersion
                        [␀] Description
                        [␀] Product
                    String __NounName           Process

    #>
    [cmdletbinding()]
    [Alias('Prop', 'ObjectProperty')]
    param(
        # any object with properties to inspect
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject,

        # Return extra information?
        [Parameter()][switch]$Detailed
    )

    begin {
        <#
        todo: to fix:

        🐒> $profile | Prop


      TypeOfInstance Name                 Value
      -------------- ----                 -----
               Int32 Length               68

        [DBG]:
        🐒> # noteproperties are there
            $profile | gm -MemberType Properties


        TypeName: System.String

        Name                   MemberType   Definition
        ----                   ----------   ----------
        AllUsersAllHosts       NoteProperty string AllU
        AllUsersCurrentHost    NoteProperty string AllU
        CurrentUserAllHosts    NoteProperty string Curr
        CurrentUserCurrentHost NoteProperty string Curr
        Length                 Property     int Length
#>

        $splat_FormatType = @{
            IgnorePrefix = 'System.Xml'
            # NoBrackets   = $false
        }

        $Config = @{
            SymbolNull = "[`u{2400}]" # [Null]
        }
        $inputList = [list[object]]::new()
    }
    process {
        $inputList.Add( $InputObject )
    }
    end {
        # Write-Warning 'should not be a raw table'
        # Write-Debug 'use: <C:\Users\cppmo_000\Documents\2020\powershell\consolidate\2020-12\custom formatting for property names\Custom format using PsTypeNames on PSCO 2020-12.ps1>'
        # | Get-Unique -OnType # ddon't force it,
        $inputList
        | ForEach-Object {
            $curObject = $_
            Write-Debug "Object: $($_.GetType().FullName)"
            $curObject.psobject.properties | ForEach-Object {
                $curProp = $_
                Write-Debug "Property: $($curProp.Name)"
                $curProp | Format-Table | Out-String | Write-Debug

                $ValueIsNull = $null -eq $curProp.Value
                if ($ValueIsNull) {
                    $DisplayedValueType = $Config.SymbolNull
                } else {
                    $DisplayedValueType = $curProp.Value.GetType()  | Format-TypeName @splat_FormatType
                }

                $meta = [ordered]@{
                    Type           = $curProp.TypeNameOfValue | Format-TypeName @splat_FormatType
                    TypeOfInstance = $DisplayedValueType
                    Name           = $curProp.Name
                    Value          = $curProp.Value
                    PsTypeName     = 'Nin.PropertyList'
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

        <# explicit, inline:
        if ($false -and 'manual typeinfo') {

            $splat_TypeData_PropertyList = @{
                TypeName                  = 'Nin.PropertyList'
                Force                     = $true
                DefaultDisplayPropertySet = 'TypeOfInstance', 'Name', 'Value', 'Type'
                # DefaultDisplayPropertySet = @('Name', 'Species', 'Age')
                DefaultDisplayProperty    = 'Name'
                # 'DefaultKeyPropertySet' = '??'
            }

            Update-TypeData @splat_TypeData_PropertyList -Force
        }
        #>
    }
}


if ($false) {
    H1 'Prop output:'
    Get-ChildItem . | Get-Unique -OnType | Select-Object -First 1 | Prop | Format-Table

    (Get-Date) | Prop | Format-Table

    Write-Warning 'bug:'


    <#
# is not returning properties on itself:
> @(34) | prop

> (34) | Prop | ExpectedToBe Blank

> @(34) | Prop | ExpectedToBe List

# Should be:
> $x.psobject.properties'
#>
}

if ($false -and $DebugTestMode) {

    $catHash = @{'a' = 'cat'; age = 9; children = (0..4) }
    $catObj = [pscustomobject]$catHash

    H1 'Test1] Param'
    $gcm = Get-Command Select-Object
    $gcm.Parameters | Prop | Format-Table

    H1 'Test2] Basic Objects'
    $catHash | Prop | Format-Table
    $catObj | Prop | Format-Table
}

if ($false -and $DebugTestMode) {

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

