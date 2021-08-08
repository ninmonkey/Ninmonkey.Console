function _listModulesWithAlias {
    <# print counts of aliases per module name#>
    Get-Alias | Group-Object Source -NoElement | Select-Object Count, Name | Sort-Object Count -Descending
}
function Get-NinAlias {
    <#
    .synopsis
        quickly find aliases declared from a list of modules
    .description
        todo: rewrite docs


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
        PS> Get-NinAlias -List

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
        [switch]$List,

        # FOrce
        [Parameter(Mandatory, Position = 0)]
        [object]$ParameterName
    )
    begin {

    }
    process {
        $meta = @{
            MyModule = @()
            NoSource = Get-Alias * | Where-Object { [string]::IsNullOrWhiteSpace( $_.Source  ) }
        }
        $myModuleNames = _enumerateMyModule
        $noModuleAlias = Get-Alias | Group-Object Source -NoElement | Where-Object { [string]::IsNullOrWhiteSpace( $_.Name ) } | Sort-Object Name
        $modules_noSource = Get-Alias | Where-Object { [string]::IsNullOrWhiteSpace( $_.Source ) }
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
    $AliasZ = Get-NinAlias *
}
if ($false -and $DebugTestMode) {
    Get-Alias * | Where-Object Source -Match 'Ninmonkey.Console'
    | Measure-Object

    hr
    $R = Get-NinAlias 'Ninmonkey.Console'
    H1 'all values'
    $R | Select-Object * -First 1
    $R | Measure-Object
    # | Select-Object Name, *name*, *command*, *module*

}
