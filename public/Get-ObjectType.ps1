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
    param(
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
