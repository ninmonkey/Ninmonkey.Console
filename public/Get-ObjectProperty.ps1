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
    future checklist
        - [ ] bugfix: tofix: Performance is really slow. Maybe it's version patching, but verify speed else goto dotnet
        - [ ] Performance: Profile if different 'properties' are super slow, return graph/metrics

        - [ ] -PropertyName[]: list of properties to Select / include
        - [ ] -ExcludePropertyName[]: list of properties to exclude

        - [ ] super slow on some instances like 'Get-PSReadLineOption | prop'
        - [ ] only int returned for: '$profile | Prop'


        - [ ] auto-truncate long typenames past a max length limit
        - [ ] only show TypeOfInstance when it doesn't match Type, easier to read
        - [ ] or use
            PS> $name | Format-TypeName -MaxLength 50
        -
        - [ ] -FilterByProp: Name
        - [ ] -FilterByValue
        - [ ] -FilterByType : or just a generic script block?
        - [x] only grab the firstN items
        - [ ] get metadata like
            - ClassExplorer\Find-Type
            - ClassExplorer\Get-Parameter
            - PSScriptTools\Get-ParameterInfo
        now defaults to one output per typename

        - [ ] performance
            - profile it, but it's really fast to just run:
                "$InputObject.psobject.properties"


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
    .example
        ,(1..4) | prop -IncludeTypeTitle
        1..4 | prop -IncludeTypeTitle
    #>
    [cmdletbinding(PositionalBinding = $false)]
    [Alias('Prop')]
    param(
        # any object with properties to inspect
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject,

        # Return extra information?
        [Parameter()][switch]$Detailed,

        # max number of input-objects
        [alias('Max')]
        [Parameter()]
        [int]$Limit, # Sci said that [uint] type has unecessary casts/additional coercion,

        # TypeName of the InputObject you are enumerating
        [Alias('TitleHeader')]
        [Parameter()][switch]$IncludeTypeTitle
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
        $_curInputCount = 1

        $Config = @{
            SymbolNull = "[`u{2400}]" # [Null]
        }
        $inputList = [list[object]]::new()
    }
    process {
        $_curInputCount++
        if ($Limit -and ($_curInputCount -gt $Limit)) {
            # maybe I can halt the pipeline, is it processing extra?
            # It's timing out somewhere.


            # Oh, I wonder if  Write-Label $null, is throwing an exception
            # causing it to stall ?
            return
        }
        $inputList.Add( $InputObject )
    }
    end {
        # Write-Warning 'should not be a raw table'
        # Write-Debug 'use: <C:\Users\cppmo_000\Documents\2020\powershell\consolidate\2020-12\custom formatting for property names\Custom format using PsTypeNames on PSCO 2020-12.ps1>'
        # | Get-Unique -OnType # ddon't force it,
        $inputList
        | ForEach-Object {
            $curObject = $_

            if ($IncludeTypeTitle) {
                $curObject.GetType() | Format-TypeName -Brackets | Join-String -op  "`nTypeName: "
                # | Label 'TypeName' # todo: once label is fixed
            }
            Write-Debug "Object: $($_.GetType().FullName)"
            $curObject.psobject.properties.count | Label '.properties count' | Write-Debug
            $curObject.psobject.properties | ForEach-Object {
                $curProp = $_
                Write-Debug "Property: $($curProp.Name)"
                $curProp | Format-Table | Out-String | Write-Debug

                $ValueIsNull = $null -eq $curProp.Value
                if ($ValueIsNull) {
                    $DisplayedValueType = $Config.SymbolNull
                }
                else {
                    $DisplayedValueType = $curProp.Value.GetType() | Format-TypeName @splat_FormatType
                }

                $abbr_TypeNameOfValue = $curProp.TypeNameOfValue -as 'type' | Format-TypeName # temp hack until refactor of Format-TypeName

                # /// -----
                $curType = $abbr_TypeNameOfValue
                $curTypeInstance = $DisplayedValueType
                if ($curType -eq $curTypeInstance) {
                    $typeAbbrString = $curType
                }
                else {
                    $typeAbbrString = '{0} ⇾  {1}' -f @(
                        $curType
                        $curTypeInstance
                    )
                }
                # $profile | Prop
                $meta = [ordered]@{
                    Type           = $abbr_TypeNameOfValue
                    # Type           = $curProp.TypeNameOfValue #| Format-TypeName @splat_FormatType
                    TypeOfInstance = $DisplayedValueType
                    Name           = $curProp.Name
                    Value          = $curProp.Value
                    TypeAbbr       = $typeAbbrString
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
