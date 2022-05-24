using namespace System.Collections.Generic
#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Search-PSReadLineKey'
        'Get-PSReadlineKeyName'

    )
    $publicToExport.alias += @(

    )
}

function Get-PSReadlineKeyName {
    <#
    .SYNOPSIS
        List all functions returned by the commandlet
    #>
    param()
    Get-PSReadLineKeyHandler -Bound -Unbound | ForEach-Object Function | Sort-Object -Unique
}
function Search-PSReadLineKey {
    <#
    .synopsis
        basic regex search on names
    .link
        Microsoft.PowerShell.KeyHandler
    #>
    param(
        # using regex search function names
        [Alias('FunctionRegex')]
        [Parameter(Position = 0)]
        [string]$FunctionPattern,
        # regex
        [Alias('KeyRegex')]
        [Parameter(Position = 1)]
        [string]$KeyPattern,

        # filter non-bound results
        [Parameter()]
        [switch]$OnlyBound,

        # filter non-bound results
        [Parameter()]
        [switch]$NotBound,

        # when off, use color
        [Parameter()]
        [switch]$PassThru
    )

    $splatBound = @{}

    # Only filter when xor, otherwise include all
    if ($OnlyBound -xor $NotBound) {
        $splatBound['Bound'] = $OnlyBound
        $splatBound['Unbound'] = $NotBound
    } else {
        $splatBound['Bound'] = $true
        $splatBound['Unbound'] = $true

    }
    $splatBound | Format-Table | Out-String | Write-Debug

    if ($PassThru) {

    }
    $query = Get-PSReadLineKeyHandler @splatBound
    | Where-Object { $FunctionPattern -and $_.Function -match $FunctionPattern }
    | Where-Object { $KeyPattern -and $KeyPattern -and $_.Chord -match $KeyPattern }

    if ($PassThru) {
        return $query
    }

    # Get-PSReadLineKeyHandler -Bound -Unbound
    Get-PSReadLineKeyHandler @splatBound
    # '(forward|backward)'
    $Query
    | Where-Object Function -Match
    | Format-Table -AutoSize -GroupBy { $true }
    | rg ('$|' + (Join-Regex -Pattern $FunctionPattern, $KeyPattern))

}
