using namespace System.Collections.Generic
#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Test-SameObjectType'

    )
    $publicToExport.alias +=
    @(

        'isA' # 'Test-SameObjectType'
        'Assert-SameObjectType' # 'Test-SameObjectType'
        # '__'  # 'Find-UnderlineMember
        '_'  # 'Find-UnderlineMember
        'Dunder'  # 'Find-UnderlineMember
        'Inspect->FindUnderline' # 'Find-UnderlineMember
        # 'Under'  # 'Find-UnderlineMember

        # '_' # 'Find-UnderlineMember
        # 'Find-UnderMember' # 'Find-UnderlineMember
        # 'Under' # 'Find-UnderlineMember
    )
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
        [Parameter(Mandatory)]
        $Left,

        # pass objects, type info, names of types, anything
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory)]
        $Right,

        # Assert instead of bool
        [Parameter()]
        [switch]$Strict
    )
    $OriginalPSTypeNames = @{
        Left  = $Left.PSTypeNames
        Right = $Right.PSTypeNames
    }
    if ($PSCmdlet.MyInvocation.InvocationName -eq 'Assert-SameObjectType') {
        $Strict = $True
    }

    $Left_tinfo = Resolve-TypeInfo
    $Right_tinfo = Resolve-TypeInfo
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
    Write-Error @writeErrorSplat
    'Potential matching types: '
    $OriginalPSTypeNames | Format-Table | Out-String | Write-Debug
}
