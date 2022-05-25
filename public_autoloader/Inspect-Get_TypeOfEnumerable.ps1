# #Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Get-TypesOfEnumerator'
    )
    $publicToExport.alias += @(
        'InspectEnumerable'  # 'Get-TypesOfEnumerator'
        'Inspect->Enumerable' # 'Get-TypesOfEnumerator'

    )
}

class CollectionTypeInfo {
    [ValidateNotNullOrEmpty()]
    [string]$Base

    [ValidateNotNullOrEmpty()]
    [string]$Child

    [int]$Count

    # quick hide until its replaced with  TypeData
    hidden [object]$BaseTypeInfo
    hidden [object]$ChildTypeInfo
}
function Get-TypesOfEnumerator {
    <#
    .synopsis
        summarize collections, or more broadly or ienumerables?
    .notes
        future: add [SupportsNoColor]

        to fix:
            gi env: | InspectEnumerable | fl
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
        'InspectEnumerable',
        'Inspect->Enumerable'
    )]
    [OutputType('CollectionTypeInfo')]
    param(
        # Any possible collections
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )
    process {
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

}
