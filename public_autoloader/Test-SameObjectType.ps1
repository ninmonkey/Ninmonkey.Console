using namespace System.Collections.Generic
#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Test-SameObjectType'
        'Test-ShareAnyValue'

    )
    $publicToExport.alias += @(

        'isA' # 'Test-SameObjectType'
        'Assert-SameObjectType' # 'Test-SameObjectType'
    )
}


function Test-ShareAnyValue {
    <#
    .synopsis
        Test if two lists share at least one value
    .description
        tests whether anything matches, to find out which elements match
        see: Compare-ShareAnyValue
    .example
        $l1 = 'a', 'e', 'cat', 'dog'
        $l2 = 'b', 'gaf', 'cat'
        PS> Test-ShareAnyValue $l1 $l2

            $true
    #>
    [OutputType([Boolean])]
    [cmdletbinding()]
    param(
        # first list
        [ValidateNotNull()][Parameter(Mandatory)]
        [object]$LeftList,

        # first second list
        [ValidateNotNull()][Parameter(Mandatory)]
        [object]$RightList
    )
    # assert ienumerable or something?

    if ($LeftList.count -eq 0 -or $RightList.count -eq 0) {
        return $false
    }

    <#

    # method1 = At least one common element
    [bool]$equalityTest = @( foreach ($item in $LeftList) {
            $item -in $RightList
        }).Where({ $_ }).count -gt 0
    # method2 = At least one common element
    [bool]$equalityTest = @( foreach ($item in $LeftList) {
            $item -in $RightList
        })
    | Dev.Nin\Test-AnyTrue

    # method 3
    @( foreach ($item in $LeftList) {
            $item -in $RightList
        })
    | Dev.Nin\Test-AnyTrue
    #>

    return $equalityTest # redundantly explicit
}




function Test-SameObjectType {
    <#
    .synopsis
        compare non (gac?) type names, for [PSCustomObjects]
    .description
    .notes
        future:
            - [ ] check for secondary types
    #>
    [OutputType('boolean', 'Exception')]
    [Alias('isA', 'Assert-SameObjectType')]
    [CmdletBinding()]
    param(
        # pass objects, type info, names of types, anything
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 0)]
        $LeftObject,

        # pass objects, type info, names of types, anything
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 1)]
        $RightObject,

        # Assert instead of bool
        [Parameter()]
        [switch]$Strict
    )
    if ($PSCmdlet.MyInvocation.InvocationName -eq 'Assert-SameObjectType') {
        $Strict = $True
    }

    $tinfo_left = Resolve-TypeInfo -InputObject $LeftObject
    $tinfo_right = Resolve-TypeInfo -InputObject $RightObject
    [bool]$areEqual = $Left_tinfo.FullName -eq $Right_tinfo.FullName
    if (! $Strict) {
        return $areEqual
    }

    # write-error -ea stop -ErrorRecord

    $writeErrorSplat = @{
        ErrorAction = 'stop'
        Category    = 'InvalidType'
        Message     = 'NotEqualTypesException: {0} != {1}' -f @(
            $Left_tinfo
            $Right_tinfo
        )
    }
    'Potential matching types: '
    $OriginalPSTypeNames | Format-Table | Out-String | Write-Debug

    # [bool]($LeftObject.PSTypeNames -contains $
    $RightObject.PSTypeNames

    Write-Error @writeErrorSplat
}

# "almost :  Test-ShareAnyValue $PSCommandPath" | Write-Warning
