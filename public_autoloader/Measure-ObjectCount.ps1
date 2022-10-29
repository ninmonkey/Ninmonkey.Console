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

# fix me
function Measure-ObjectCount {
    <#
    .synopsis
        Simple. Counts items. Shortcut for the cli, simplifed version of Dev.Nin\Measure-ObjectCount
    .description
       This is for cases where you had to use

        PS> ... | Measure-Object | % Count | ...
    .notes
        warning: currently iterates more than once
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
        # // number of iterations
        [int]$pipeLineCount = 0
        if ($IgnoreBlank) {
            'nyi: next'
        }
    }
    process {

        # $objectList.AddRange( $InputObject )

        $pipeLineCount++
        # todo: ignore null, ignore blannk to process block
        # if( ! $IgnoreBlank ) {
        #     $Item = $InputObject
        # } else {
        #     $Item = $InputObject
        #     | Dev.Nin\?NotBlank
        # }
        # if($Item) {
        #     $objectList.AddRange(
        # }

    }
    end {

        $IgnoreBlankCount = $ObjectList
        | Dev.Nin\Where-IsNotBlank
        | Measure-Object | ForEach-Object Count

        $arrayCount = $objectList.Count
        <#
            or
                $ObjectList
                | Measure-Object | ForEach-Object Count

        #>


        $dbg = [ordered]@{
            PipelineCount    = $pipeLineCount
            arrayCount       = $arrayCount
            ignoreBlankCount = $IgnoreBlankCount
            IgnoreBlank      = $IgnoreBlank
            PassThru         = $PassThru
        }
        # if($IgnoreBlank) {

        # }
        if ( ! $PassThru ) {
            # normal returns int, else object with infa action
            if ($IgnoreBlank) {
                return $ignoreBlankCount
            } else {
                return $arrayCount
            }
        }

        $dbg | Format-Table -AutoSize -Wrap | Out-String | Write-Verbose


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
