#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        '_sortBy_Get-Alias'
    )
    $publicToExport.alias += @(
        'Sort->Alias' # '_sortBy_Get-Alias'
    )
}

function _sortBy_Get-Alias {
    <#
    .synopsis
        sugar for pipeline sorting of aliases
    .description
        is a template for the SortBy_* series of functions
    #>
    [OutputType( [System.Management.Automation.AliasInfo] )]
    [Alias('Sort->Alias')]
    [cmdletbinding()]
    param(
        # expects [AliasInfo]
        [Parameter(ValueFromPipeline, Mandatory)]
        [object[]]$InputObject,

        # return as objects
        [Parameter()][switch]$PassThru
    )
    begin {
        $objects = [list[object]]::new()
    }
    process {
        $Objects.AddRange( $InputObject )
    }
    end {
        $sorted = $Objects | Sort-Object Source, ReferencedCommand -Descending
        if ($PassThru) {
            return $sorted;
        }

        $sorted
        | Format-Wide DisplayName -Column 1 -GroupBy Source

    }
}
