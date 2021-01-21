function _listModulesWithAlias {
    <# print counts of aliases per module name#>
    Get-Alias | Group-Object Source -NoElement | Select-Object Count, Name | Sort-Object Count -Descending
}
function Get-NinAlias {
    <#
    .synopsis
        quickly find aliases declared from a list of modules
    .description
        PS> Get-NinAlias Microsoft.PowerShell.Management

            CommandType Name                    Version Source
            ----------- ----                    ------- ------
            Alias       gcb -> Get-Clipboard    7.0.0.0 Microsoft.PowerShell.Management
            Alias       gin -> Get-ComputerInfo 7.0.0.0 Microsoft.PowerShell.Management
            Alias       gtz -> Get-TimeZone     7.0.0.0 Microsoft.PowerShell.Management
            Alias       scb -> Set-Clipboard    7.0.0.0 Microsoft.PowerShell.Management
            Alias       stz -> Set-TimeZone     7.0.0.0 Microsoft.PowerShell.Management

    .example
        PS> Get-NinAlias 'Ninmonkey' # will find partial matches
    .example
        # Show modules that contain any aliases
        PS> Get-NinAlias -List

            Count Name
            ----- ----
            138
            44 PSScriptTools
            28 Ninmonkey.Console
            12 Dev.Nin
            5 Microsoft.PowerShell.Management
            3 Configuration
            2 Pansies
            1 chocolateyProfile
            1 EditorServicesCommandSuite
            1 Microsoft.PowerShell.Utility
            1 PowerShellEditorServices.Commands
    .notes

    future:
        - [ ] dynamic completer the modules from -list
    #>
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    param (
        # Pattern of module, regex
        [Parameter(
            ParameterSetName = 'Search',
            Mandatory, Position = 0)]
        [string[]]$ModuleSource,

        # Scope
        [Parameter(ParameterSetName = 'Search')]
        [string]$Scope,

        # List current modules with aliases
        [Parameter(ParameterSetName = 'ListOnly')]
        [switch]$List
    )
    begin {

    }
    process {
        if ($list) {
            _listModulesWithAlias
            return
        }

        $ModuleSource  | ForEach-Object {
            $curModule = $_

            Get-Alias -Scope $Scope | Where-Object {
                $_.Source -match $curModule
            }
        }
    }
    end {}
}

if ($DebugTestMode) {
    Get-Alias * | Where-Object Source -Match 'Ninmonkey.Console'
    | Measure-Object

    hr
    $R = Get-NinAlias 'Ninmonkey.Console'
    H1 'all values'
    $R | Select-Object * -First 1
    $R | Measure-Object
    # | Select-Object Name, *name*, *command*, *module*

}