function Get-NinCommand {
    <#
    .synopsis
        Get-Command wrapper for the CLI
    .notes
        future:
        - [ ] use 'ProxyCommand'?
    #>
    [CmdletBinding()]
    param (
        # docstring
        [Parameter(Position = 0)]
        [string[]]$CommandName,

        [Parameter()]
        [string[]]$ModuleName = ''

    )

    begin {
        Write-Warning 'kinda nyi / needs refactor. finds non-nin commands'
        $userFavModules = @(
            'ClassExplorer'
            'Dev.Nin'
            'EditorServicesCommandSuite'
            'Ninmonkey.Console'
            'Ninmonkey.Powershell'
            'Pansies'
            'PowerShellEditorServices.Commands'
            'PowerShellEditorServices.VSCode'
            'PSReadLine'
        )

        $finalSortOrder = 'Source', 'Version', 'Name', 'CommandType'

        $gcmDefault_splat = @{
            # 'Module' = $ModuleName
            # 'Name'   = $CommandName
            # 'CommandType'  ''
            # 'TotalCount'  3
            # 'Syntax'
            # 'ShowCommandInfo'
            # 'All'
            # 'ListImported'
            # 'ParameterName'  'a', 'b'
            # 'ParameterType'  'int', 'string'
            # 'FullyQualifiedModule'  'spec'
            # 'UseFuzzyMatching'
            # 'UseAbbreviationExpansion'
        }
    }
    process {
        # if (!($null -eq $ModuleName)) {
        # }
        if (!($ModuleName)) {
            $gcmDefault_splat['Module'] = $userFavModules
        }
        else {
            $gcmDefault_splat.Module = $ModuleName
        }

        if (!($null -eq $CommandName)) {
            $gcmDefault_splat['Name'] = $CommandName
        }
        $gcmDefault_splat | Format-HashTable | Write-Debug
        $ninGcm_splat = $gcmDefault_splat
        $ninGcm_splat | Format-HashTable | Write-Debug

        Get-Command @ninGcm_splat
        | Sort-Object -Property $finalSortOrder
        # | Join-String { $_.Source, $_.Name -join '\' } -Separator "`n"
        # | Sort-Object
        # | ForEach-Object { $_ -split '\n' }  # here
        # | Join-String -Sep ', '

    }
}

function __Format-Command {
    # other types 'Alias', 'Function', 'Cmdlet', 'ExternalScript', 'Application'
    # why logic inside Join-Str? Just to try it.
    $joinStr_splat = @{
        Separator = "`n"
        Property  = {
            switch ($this.CommandType) {
                'Cmdlet' {
                    $this.Source, $this.Name -join '\'
                    break
                }
                'Application' {
                    '{0} ( {1} )' -f @(
                        $this.Name
                        $this.Source
                        break
                    )
                }
                default {
                    '<no>'
                }
            }
        }
    }

    Get-Command '*name*'
    | Sort-Object -Prop 'Source', 'Version', 'Name', 'Command'
    | Join-String @joinStr_splat
    # | Sort-Object -Unique
    throw 'not yet working'
}
