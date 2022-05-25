# #Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Get-CollectionTypeInfo'
    )
    $publicToExport.alias += @(
        'InspectCollection'  # 'Get-TypesOfEnumerator'
        'Inspect->Collection' # 'Get-TypesOfEnumerator'

    )
}

class CollectionTypeInfo {
    [ValidateNotNullOrEmpty()]
    [string]$Base

    [ValidateNotNullOrEmpty()]
    [string]$Child

    [int]$Count

    # quick hide until its replaced with  TypeData
    [object]$BaseTypeInfo
    [object]$ChildTypeInfo
}
function Get-CollectionTypeInfo {
    <#
    .synopsis
        summarize collections, or more broadly or ienumerables?
    .notes
        future: add [SupportsNoColor]

        to fix:
            gi env: | InspectEnumerable | fl

        see class explorer:
                Find-Type -Signature { [generic[exact[System.Collections.Generic.IEnumerable`1, args[mytype]]]] } -map @{ 'mytype' = $arg }

                Find-Type -Implements System.Collection.IDictionary
    .example
        ps> $cmd = Get-Command -Name Get-Culture
        ps> $cmd.Parameters | InspectEnumerable

            Base          : [Dictionary<string, ParameterMetadata>]
            Child         : [KeyValuePair<string, ParameterMetadata>]
            Count         : 14
            BaseTypeInfo  : System.Collections.Generic.Dictionary`2[System.String,System.Manag
                            rMetadata]
            ChildTypeInfo : [Name, System.Management.Automation.ParameterMetadata]
    #>
    [Alias(
        'InspectCollection',
        'Inspect->Collection'
    )]
    [OutputType('CollectionTypeInfo')]
    param(
        # Any possible collections
        [Parameter(Mandatory, Position = 0)]
        $InputObject
    )


    # return 32
    [CollectionTypeInfo]@{
        Base          = $InputObject | Get-Unique -OnType | shortType
        Child         = $InputObject.GetEnumerator() | Select-Object -First 1 | shortType
        Count         = $InputObject.Count
        BaseTypeInfo  = $InputObject.GetType()
        ChildTypeInfo = @($InputObject.GetEnumerator())[0] # is one bettter?
        # IsDict = 'nyi'
        # IsIEnumerable 'nyi'
        # IsList/Arrary 'nyi'
        # IsEmptyList = 'sdf'
    }


}

<#

    nce of DictionaryEntry t
#>
