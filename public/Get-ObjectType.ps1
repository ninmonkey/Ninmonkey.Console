
function Get-ObjectType {
    <#
    .synopsis
        simplify getting type name of an object and child types
    .example
    .notes
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

        # All: Test all elements similar to Select-Object -Wait
        [Parameter()][switch]$All
    )

    process {
        $cur = $InputObject

        $meta = @{
            Type      = $cur.GetType()
            | Format-TypeName -WithoutBrackets

            TypeNames = $cur.pstypenames | Join-String -sep ', ' -OutputPrefix '{ ' -OutputSuffix ' }'

            Count     = $cur.Count

        }



        # [pscustomobject]$meta
        $meta
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

    H1 'enumerate all'
    $results = foreach ($Key in $items.Keys) {
        [pscustomobject]@{
            Label    = $Key
            Contents = $items[$Key]
            Type     = $items[$Key] | ForEach-Object gettype #| Format-TypeName -WithoutBrackets
        }
    }
    $results

    H1 'inner results'
    foreach ($Item in $Results) {
        H1 $Item.Label
        $Item.Contents

    }
    # foreach ($Key in $results.GetEnumerator()) {
    #     $Key = $_.Key
    #     $Value = $_.Value

    #     H1 $Key
    #     $Value
    # }
}