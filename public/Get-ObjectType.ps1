function Get-ObjectType {
    <#
    .synopsis
        simplify getting type name of an object and child types
    .example
    .notes
    future:
        - simplify showing
            - interfaces implemented
            - base/parent type
            - category = class, enum, typeReflectionInfo
    #>
    [Alias('TypeOf')]
    param(
        # InputObject[s] to get type[s] of
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        throw "NYI: Left off. todo:
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

    }
}


if ($true) {
    # test cases
    $mod = Get-Module 'Ninmonkey.Console'
    $cmd = Get-Command 'Get-Item'
    $nums = 2, 4, 55
    $hash = @{Species = 'cat' }
    $psobj = [pscustomobject]$hash


    34 | Get-ObjectType
    'sdf' | Get-ObjectType

    , 100 | Get-ObjectType
}