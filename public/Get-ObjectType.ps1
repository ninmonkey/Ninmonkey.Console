
function Get-ObjectType {
    <#
    .synopsis
        simplify getting type name of an object and child types
    .example

        ls | sort -Unique { $_.GetType().FullName }  | TypeOf
    .notes
        rename to Get-TypeName? Get-ItemTypeName? Get-TypeInfo?
    future:

        - [ ] custom object type, because
            - [ ] display output uses | Format-TypeName
            - [ ] but properties are still full 'Type' instances
    future:
        - simplify showing
            - interfaces implemented
            - base/parent type
            - category = class, enum, typeReflectionInfo

    future?
    #>
    <#
        "NYI: Left off. todo:
        - for objects
            - [ ] obj.GetType()
            - [ ] isContainer?
            - [ ] @(obj)[0].GetType()
            - [ ] obj.pstypenames
            - [ ] @(obj)[0].pstypenames
        - for [typeinfo]
            - [ ] @(obj)[0].GetTypeInfo()
            - [ ] obj.pstypenames ?
            - [ ] @(obj)[0].pstypenames ?
        "
        #>
    [Alias('TypeOf')]
    param(
        # InputObject[s] to get type[s] of
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject,

        # show more information , or todo: refactor as custom view type
        [Parameter()][switch]$Detail,

        # ignore colors using: PassThru (until refactor to move colors to format types)
        [Parameter()][switch]$PathThru

        # All: Test all elements similar to Select-Object -Wait
        # [Parameter()][switch]$AllElements

    )
    begin {
        $UseColor = ! $PathThru
        $joinAsList_splat = @{
            Separator    = ', '
            OutputPrefix = '{'
            OutputSuffix = '}'
        }

        $joinTypesAsList_splat = @{
            Separator    = ', '
            OutputPrefix = '{'
            OutputSuffix = '}'
            Property     = { $_ | Format-TypeName -WithBrackets }
        }

        # vs code has issues with non-printable characters in table widths
        if ((Get-TerminalName).IsVSCode) {
            $UseColor = $false
        }

        if ($UseColor) {
            # Warning: Refactor to custom view, not raw output!
            $ColorDarkGrey = 'aaaaaa'
            $splatDarkGrey = @{
                ForegroundColor = $ColorDarkGrey
            }

            # giant spam until refactor as formatter
            $joinTypesAsList_splat.OutputPrefix = New-Text @splatDarkGrey $joinTypesAsList_splat.OutputPrefix | ForEach-Object tostring
            $joinTypesAsList_splat.OutputSuffix = New-Text @splatDarkGrey $joinTypesAsList_splat.OutputSuffix | ForEach-Object tostring
            $joinTypesAsList_splat.Separator = New-Text @splatDarkGrey $joinTypesAsList_splat.Separator | ForEach-Object tostring

            $joinAsList_splat.OutputPrefix = New-Text @splatDarkGrey $joinAsList_splat.OutputPrefix | ForEach-Object tostring
            $joinAsList_splat.OutputSuffix = New-Text @splatDarkGrey $joinAsList_splat.OutputSuffix | ForEach-Object tostring
            $joinAsList_splat.Separator = New-Text @splatDarkGrey $joinAsList_splat.Separator | ForEach-Object tostring
        }

    }

    Process {
        $cur = $InputObject
        $element1 = $InputObject | Select-Object -First 1



        $meta = [ordered]@{
            Count  = $cur.Count
            isList = $cur.Count -gt 1
            Type   = $cur.GetType() | Format-TypeName
        }

        $metaDetailed = [ordered]@{
            elementType   = $element1.GetType() | Format-TypeName
            | Format-TypeName

            # elementTypeNames     = $element1.pstypenames | Join-String @joinAsList_splat # { $_ | Format-TypeName }
            # elementTypeNamesAbbr = $element1.pstypenames | Join-String @joinAsList_splat -prop { $_ | Format-TypeName }

            TypeNames     = $cur.pstypenames | Join-String @joinTypesAsList_splat
            TypeNamesFull = $cur.pstypenames | Join-String @joinTypesAsList_splat
            # TypeNames     = $cur.pstypenames | Join-String @joinAsList_splat -prop { $_ | Format-TypeName }
            # TypeNamesAbbr = $cur.pstypenames | Join-String @joinAsList_splat -prop { $_ | Format-TypeName }
        }

        if ($Detail) {
            $meta += $metaDetailed
        }

        # if ($AllElements) {
        #     $AllTypeList = $InputObject | ForEach-Object {
        #         $_ | ForEach-Object GetType
        #         | Format-TypeName -WithBrackets
        #     } | Join-String @joinAsList_splat
        #     $meta.Add('AllTypeList', $AllTypeList )
        # }

        [pscustomobject]$meta
        # $meta
    }
}


if ($isdebugmode) {
    # test cases
    $items = [ordered]@{}
    $items.mod = Get-Module 'Ninmonkey.Console'
    $items.cmd = Get-Command 'Get-Item'
    $items.nums = 2, 4, 55
    $items.hash = @{ Species = 'cat'; }
    $items.object = [pscustomobject]($items['hash'])
}

if ($false) {
    H1 'mod'
    $items.mod | TypeOf
    H1 'sdf'
    hr
    234, 'sdf' | TypeOf
    hr
    TypeOf 'dog' | Format-Table
    hr
    TypeOf 'dog' -Detail | Format-Table

    # # final
    # hr;
    # $items.mod | TypeOf
    # hr;
    # $items.cmd | TypeOf
    # hr;
    # $items.nums | TypeOf
    # hr;
    # $items.hash | TypeOf
    # hr;
    # $items.object | TypeOf
    # hr
}

if ($false) {
    H1 'enumerate all'
    $results = foreach ($Key in $items.Keys) {
        [pscustomobject]@{
            Label    = $Key
            Contents = $items[$Key]
            Type     = $items[$Key] | ForEach-Object gettype #| Format-TypeName -Brackets
        }
    }
    $results

    H1 'inner results'
    foreach ($Item in $Results) {
        $H2splat = @{
            ForegroundColor = 'magenta'
            Depth           = 2
        }

        H1 $Item.Label @H2splat
        $Item.Contents

    }
    # foreach ($Key in $results.GetEnumerator()) {
    #     $Key = $_.Key
    #     $Value = $_.Value

    #     H1 $Key
    #     $Value
    # }
}
