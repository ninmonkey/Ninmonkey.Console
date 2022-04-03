using namespace System.Collections.Generic
#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Measure-ObjectCount'

    )
    $publicToExport.alias += @(
        'Count', 'Len'
    )
}

function Measure-ObjectCount {
    <#
    .synopsis
        Simple. Counts items. Shortcut for the cli, simplifed version of Dev.Nin\Measure-ObjectCount
    .description
       This is for cases where you had to use

        PS> ... | Measure-Object | % Count | ...
    .notes
        future:
            - Parameter <condition> that works how Sort-Object's -Property param works
                for custom counting conditions?
    .example
        🐒> ls . | Count # how many files?
        4

        🐒> ClassExplorer\Find-Type *xml* | len

            # prints
            235
    .outputs
          [int]
    .link
        Dev.Nin\Where-IsNotBlank
    .link
        Ninmonkey.Console\Measure-ObjectCount

    #>

    [alias( 'Count', 'Len')]
    [CmdletBinding()]
    param(
        #Input from the pipeline
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        # do not count 'Blank' values
        [Alias('IgnoreNull')]
        [Parameter()][switch]$IgnoreBlank,

        [switch]$PassThru

    )
    begin {
        $objectList = [List[object]]::new()
    }
    process {
        $objectList.AddRange( $InputObject )

    }
    end {
        if ($PassThru) {
            $objectList
            | ForEach-Object {
                if ($IgnoreNull) {
                    $_ | Dev.Nin\Where-IsNotBlank
                } else {
                    $_
                }

            }
            | Measure-Object
            | ForEach-Object Count

        }
        # if ($IgnoreBlank) {
        #     $objectList
        #     | Dev.Nin\Where-IsNotBlank
        #     | Measure-Object | ForEach-Object Count
        # } else {
        #     $objectList
        #     | Measure-Object | ForEach-Object Count
        # }
    }
}
