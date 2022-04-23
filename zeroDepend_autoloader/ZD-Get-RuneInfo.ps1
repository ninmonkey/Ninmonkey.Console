#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'ZD-Get-RuneInfo'
    )
    $publicToExport.alias += @(
        'zd-RuneInfo' # 'ZD-Get-RuneInfo'
    )
}


function ZD-Get-RuneInfo {
    <#
    .synopsis
        get different stats , like length
    .example

    #>
    [ALias('zd-RuneInfo')]
    [CmdletBinding()]
    param(
        # allow any stringlike input
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [AllowNull()]
        [string[]]$InputObject = [string]::Empty
    )
    begin {
        # I'm not rendering, so [Text.StringBuilder] doesn't help as much
        [list[string]]$lines = [list[string]]::new()
    }
    process {
        $lines.AddRange( [string[]]@($InputObject)  )
    }
    end {
        $Lines | ForEach-Object {
            $text = $_

            [ninRuneInfo]@{
                Source = $_
            }

        }
    }
}

class ninRuneInfo {
    [object]$Source # or

    <#
    I think length returns the number of code-units
        ie: number of [utf16-le] 2-byte segments
    #>
    [int]$CharLength


}

Write-Warning 'got caught, finish WIP '
# ZD-Get-RuneInfo '🐱🦎' -ea continue
