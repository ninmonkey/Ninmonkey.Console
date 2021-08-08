function Get-NinModule {
    <#
    .synopsis
        Get-module all my modules, one easy command.
    .description
        todo: wip:
    .outputs
    .link
        Import-NinModule
    .link
        Get-NinAlias
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

        $groupDict['Mine'] = _enumerateMyModule # this func should already be loaded

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
        $groupDict['Mine'] ??= _enumerateMyModule
    }
    process {
        $selectedModuleNames = $GroupNames | ForEach-Object {
            if ($groupDict.ContainsKey($_)) {
                $groupDict[$_]
            }
        }

        $selectedModuleNames | Join-String -sep ', ' -op 'Selected: ' | Write-Debug

        if ($selectedModuleNames.count -eq 0) {
            Write-Error 'No Matching Modules'
            return
        }

        Get-Module -Name $selectedModuleNames
        # $keyNames = $groupDict.Keys | Where-Object { $_ -in $GroupNames }
        # $keyNames = $keyNames ??= $groupDict['Mine']
        # $keyNames | Join-String -sep ', ' -SingleQuote -op 'keys: ' | Write-Debug

        # $selectedModules =  %{
        #     $groupDict.keyys
        # }

        # Get-Module -Name * | Where-Object { $_.Name -in $keyNames }

        # Get-Module -Name $selectedModules
        # | Sort-Object -Unique Name

    }
    end {}
}
