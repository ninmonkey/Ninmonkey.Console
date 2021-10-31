using namespace System.Management.Automation
$script:publicToExport.function += @(
    'Get-NinPSReadlineHistory'
)
$script:publicToExport.alias += @(
    'getHistory'
)
# $script:publicToExport.alias += @('Find-Exception')

function Get-NinPSReadlineHistory {
    <#
    .synopsis
        Currently just an alias to the function
    .description
        Get command history (with metadata) vs Grepping PSReadLine's history path
    .example
    .notes
        future:
            - [ ] supportsPaging: -first X, -Last x
            - [ ] custom view formatting
    #>
    [Alias('getHistory')]
    [CmdletBinding(PositionalBinding = $false)]
    param (
        # Warning, very slow
        [Parameter()][switch]$IncludeProfile
    )
    [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems()

    if ($IncludeProfile) {
        $profile.PSReadLineHistory | Get-Content
    }
}
