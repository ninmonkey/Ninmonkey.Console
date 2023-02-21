#Requires -Version 7



if ( $publicToExport ) {
    $publicToExport.function += @(
        'Select-ListExpression'
    )
    $publicToExport.alias += @(
        'Grab' # 'Select-ListExpression
        'Slice.Basic' # 'Select-ListExpression

    )
}



function Select-ListExpression {
    # number selects the first 3 objects from the pipeline
    <#
    .SYNOPSIS
        Grab the first N objects from the pipeline

    .NOTES
        possible sugar

        grab 3
        grab 1, 4
        grab 1, -1   # first and last
        grab 3 -last
        grab at 4
        grab at -1
        grab max 4 # maxCounts

        grab '4..6'


    #>
    [ALias('Grab','Slice.Basic')]
    [CmdletBinding()]
    param(
        [ArgumentCompletions(
            '1',
            '1, 4',
            'at 2',
            '1, -1',
            '3 -last',
            'at -1',
            'max 4'
        )]
        [Parameter(Mandatory, Position = 0)]
        [string]$QueryString,

        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,


        [int]$MaxCount = 3,
        [switch]$WhatIf
    )

    begin {
        [int]$count = 0

        $parse = @{ Raw = $QueryString.trim() }
        $parse | write-verbose
    }
    process {
        if ($count -lt $number) {
            $count++
            $_
        }
    }
    end {
        "Grabbed $count objects" | Write-Information
    }

}