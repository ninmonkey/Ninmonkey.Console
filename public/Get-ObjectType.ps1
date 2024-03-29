﻿function Get-ObjectType {
    [Alias('TypeOf')]
    <#
    .notes
        parametersets 2 position-type  modes
            1]  object[] | TypeOf mode
            2]  TypeOf object[] mode

        todo: FormatTypeName that does 'abbreviateNamespace'

    pipeline notes:
        It seems like for this function I should go with
        - parameter type that is not an array [obj]
        - process returns array ', $array'
        - then optionally enumerate on [obj] if I want to inspect child element


    .example
        $f = ls . -File | first 1
        $d = gi .
        $time = get-date
        $ps = ps * | first 1

        $f, $d, $time, $ps | typeof

        'see also'
        $otherCommands = @(
            'Dev.Nin\Get-DevInspectObject'
            'Dev.Nin\What-TypeInfo'
            'Ninmonkey.Console\Get-ObjectType'
                [me] : 'TypeOf'
        ) | resCmd -QualifiedName
    #>
    param(
        # InputObject[s] to get type[s] of
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        # Format Mode
        [Parameter()]
        [ValidateSet('List', 'PSTypeNames', 'GetType')]
        [string]$Format,

        # Returns type as Typeinfo if possible
        [Parameter()][switch]$PassThru,

        # Returns a unique list of types
        [Parameter()][switch]$Unique


    )
    begin {

        # if ($PassThru) {
        #     throw "NotImplementedError: -PassThru"
        # }
        [System.Collections.Generic.List[Object]]$typeList = @()
        if ([string]::IsNullOrWhiteSpace( $Format)) {
            $Format = 'GetType'
        }

    }
    process {
        # Write-Error 'rewrite from scratch'
        $typeList.Add( $InputObject )
    }
    end {
        write-warning "nyi: Get-ObjectType => $PSCommandPath"
        # Write-Error 'rewrite from scratch'
        # $

        switch ($Format) {

            'GetType' {
                if ($Null -eq $curObject) {
                    Write-Error '$CurObject is null'
                    continue
                }
                $typeInstance = $curObject.GetType()
                if ($PassThru) {
                    $typeInstance
                    continue
                }
                $typeInstance | Format-TypeName
                continue
            }

            { 'PSTypeNames' -or 'List' } {
                if ($PassThru) {
                    , $curObject.pstypenames
                    continue
                }

                # foreach ($Obj in $InputInputObjectect) {
                $splat_JoinPSTypeName = @{
                    Separator = ', '
                    Property  = { $_ | Format-TypeName }
                }

                $curObject.pstypenames | Join-String @splat_JoinPSTypeName
                continue
            }

            default {
                Throw "UnhandledCase: $Format"
            }
        }
    }
}


function old_Get-ObjectType {
    <#
    .synopsis
        simplify getting type name of an object and child types
    .example
        PS> ls | Get-Unique -OnType | TypeOf

            Count isList Type
            ----- ------ ----
            1  False IO.DirectoryInfo
            1  False IO.FileInfo

    .example

        ls | sort -Unique { $_.GetType().FullName }  | TypeOf
        ls . | sort { $_.GetType().Fullname } | Get-Unique -OnType | typeof

    .notes
        rename to Get-TypeName? Get-ItemTypeName? Get-TypeInfo?

    future:
        - [ ] output custom object type of this commands results, because
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
    # [Alias('TypeOf')]
    [cmdletbinding(PositionalBinding = $false)]
    param(
        # InputObject[s] to get type[s] of
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        # (to refactor as a custom Format.ps1xml) include more properties
        [Parameter()][switch]$Detail,

        # output format mode
        [Parameter(Position = 0)]
        [ValidateSet('', 'PSTypeNameList', 'Table', 'Default')]
        [string]$FormatMode = 'PSTypeNameList',


        # ignore colors using: PassThru (until refactor to move colors to format types)
        # skip colors and returns an array of PSTypeNames
        [Parameter()][switch]$PassThru

        # All: Test all elements similar to Select-Object -Wait
        # [Parameter()][switch]$AllElements

    )
    begin {
        $UseColor = ! $PassThru
        $joinAsList_splat = @{
            Separator    = ', '
            OutputPrefix = '{ '
            OutputSuffix = '}'
        }

        $joinTypesAsList_splat = @{
            Separator    = ', '
            OutputPrefix = '{ '
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
        # curTypeObj = instance of Object
        # curTypeInfo = [type] of Object
        if ($InputObject -is 'type') {
            $curTypeInfo = $InputObject
            $curTypeObj = $InputObject
        } elseif ($InputObject -is [string]) {
            $curTypeInfo = $InputObject -as [type]
            if ($null -eq $curTypeInfo) {
                throw "Failed on typeName: '$curTypeInfo'"
            }
            $curTypeObj = $null
        } else {
            $curTypeInfo = $InputObject.GetType()
            $curTypeObj = $InputObject
        }
        # if has children
        $element1 = $InputObject | Select-Object -First 1

        if ($FormatMode -eq 'Default') {
            # if assembly is verbose, replace FullName with 'namespace', 'name' to strip assembly
            #no $PassThru ?
            $tinfo = $curTypeInfo.Namespace, $curTypeInfo.Name -join '.'
            # $tinfo = $curTypeInfo.GetType().Namespace, $curTypeInfo.GetType().Name -join '.'
            $tinfo
            return

        }
        if ($FormatMode -eq 'PSTypeNameList') {
            if ($PassThru) {
                if ($curTypeObj) {
                    , $curTypeObj.PSTypeNames
                }
                return
            }
            # *should* work regardless if process inputs an array or one elemenent
            # foreach($item in $InputObject) {}
            $splat_JoinPSTypeName = @{
                Separator    = "`n- "
                OutputPrefix = '- '
                Property     = { $curTypeObj.PSTypeNames | Format-TypeName -WithBrackets | Join-String -sep ', ' }
            }

            $InputObject | Join-String @splat_JoinPSTypeName

            # $splat_JoinPSTypeNamedsf = @{
            #     OutputPrefix = { $_.PSTypeNames | Format-TypeName -WithBrackets |  Join-String -sep ', ' }
            # }

            # $InputObject | Join-String @splat_JoinPSTypeName


            return
        }



        $meta = [ordered]@{
            Count  = $curTypeObj.Count
            isList = $curTypeObj.Count -gt 1
            Type   = $curTypeObj.GetType() | Format-TypeName
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


if ($isDebugMod) {
    # test cases
    $items = [ordered]@{}
    $items.mod = Get-Module 'Ninmonkey.Console'
    $items.cmd = Get-Command 'Get-Item'
    $items.nums = 2, 4, 55
    $items.hash = @{ Species = 'cat'; }
    $items.object = [pscustomobject]($items['hash'])
    $items.GetEnumerator() | ForEach-Object { $_.Value } | ForEach-Object gettype | ForEach-Object FullName

    H1 'try 1: As Obj Instance (required)'
    $items.GetEnumerator() | ForEach-Object { $_.Value }
    | ForEach-Object FullName
    | TypeOf

    H1 'try 2: As Type instance (optional)'
    $items.GetEnumerator() | ForEach-Object { $_.Value }
    | ForEach-Object gettype | ForEach-Object FullName
    | TypeOf
}

if ($false) {
    H1 'mod'
    $items.mod | TypeOf
    H1 'sdf'
    Hr
    234, 'sdf' | TypeOf
    Hr
    TypeOf -InputObject 'dog' | Format-Table
    Hr
    TypeOf -InputObject 'dog' -Detail | Format-Table

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

if ($true -and $isDebugMod) {
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
