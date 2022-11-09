using namespace System.Collections.Generic
#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Search-PSReadLineKey'
        'Get-PSReadlineKeyName'
        'Get-PSReadLineKeyHandler.nin'

    )
    $publicToExport.alias += @(

    )
}

function Get-PSReadlineKeyName {
    <#
    .SYNOPSIS
        List all functions returned by the commandlet
    .link
        Get-PSReadlineKeyName
    .link
        Get-PSReadLineKeyHandler.nin
    .link
        Search-PSReadLineKey
    #>
    param()
    Get-PSReadLineKeyHandler -Bound -Unbound
    | ForEach-Object Function | Sort-Object -Unique
}

function Get-PSReadLineKeyHandler.nin {
    <#
    .SYNOPSIS
        simpler version of 'Search-PSReadLineKey'
    .link
        Get-PSReadlineKeyName
    .link
        Get-PSReadLineKeyHandler.nin
    .link
        Search-PSReadLineKey
    #>
    param(
        [switch]$Bound, [switch]$Unbound
    )
    $splat = @{}
    if ($Bound) { $splat['Bound'] = $true }
    if ($UnBound) { $splat['Bound'] = $true }

    $splat_getKey = mergeHashtable -BaseHash @{
        Bound   = $Bound
        Unbound = $Unbound
    }

    Get-PSReadLineKeyHandler @splat_getKey
}



function Search-PSReadLineKey {
    <#
    .synopsis
        basic regex search on names
    .link
        Microsoft.PowerShell.KeyHandler
    .link
        Get-PSReadlineKeyName
    .link
        Get-PSReadLineKeyHandler.nin
    .link
        Search-PSReadLineKey
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
    }
    else {
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
