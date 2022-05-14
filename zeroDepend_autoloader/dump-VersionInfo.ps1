

if ( $publicToExport ) {
    $publicToExport.function += @(
        '_dumpVersionInfo'
    )
    $publicToExport.alias += @(

    )
}



function _dumpVersionInfo {
    # dump versions for bug reports
    param(
        [string[]]$FilterModuleName
    )

    if ( [string]::IsNullOrWhiteSpace($FilterModuleName) ) {
        $FilterModuleName = @(
            '^Microsoft\.'
            'Microsoft.PowerShell.Management'
            'Microsoft.PowerShell.Utility'
        )
    }
    $render = Get-Module
    | Where-Object {
        foreach ($Pattern in $FilterModuleName) {
            if ($_.Name -match $pattern) {
                return $false
            }
            return $true
        }
    }
    | Join-String -sep "`n" { $_.Name, $_.Version -join ': ' } | Sort-Object -Unique
    if ($ENV:NO_COLOR) {
        return $render
    }
    $render | bat -l yml
}
