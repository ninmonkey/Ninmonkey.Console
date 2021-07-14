
function Get-NinModule {
    <#
    .synopsis
        Get-module all my modules, one easy command.
    .description

    .outputs
    .link
        Get-NinCommand
    .link
        Get-NinCommandSyntax

    #>
    [CmdletBinding(PositionalBinding = $false)]
    param(
        # List of modules groups
        [ValidateSet('Mine', 'Fav', 'Util', 'Native')]
        [Parameter(Position = 0)]
        [string[]]$GroupNames = 'Mine'
    )

    begin {
        [hashtable]$groupDict = @{}

        $groupDict['Mine'] = _enumerateMyModules

        $groupDict['Fav'] = @(
            'ClassExplorer'
            'Pansies'
            'posh-git'
            'ImpliedReflection'
            'PSFzf'
            'PSReadLine'
        ) | Sort-Object -Unique

        $groupDict['Util'] = @(
            'ClassExplorer'
            'Configuration'
            'posh-git'
            'PSFzf'
            'Pansies'
            'ImpliedReflection'
            'PSReadLine'
            'PSScriptTools'
            'chocolateyProfile'
        ) | Sort-Object -Unique
    }
    process {
        $keyNames = $groupDict.Keys | Where-Object { $_ -in $moduleNames }
        $selectedModules = $groupDict.GetEnumerator() | Where-Object { $_.Key -in $moduleNames }
        | ForEach-Object Value | Sort-Object -Unique

        $selectedModules | Join-String -sep ', ' -SingleQuote  -op 'SelectedModules: '
        | Write-Debug

        $selectedModules ??= $groupDict['Mine']
        Get-Module -Name $selectedModules
        | Sort-Object -Unique Name

    }
    end {}
}
