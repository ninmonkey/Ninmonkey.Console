function Get-NinCommandProxy {
    <#
    .synopsis
        [proxy] Wraps the built-in version of 'Get-Command'
    .description
        basically Get-Command with specific defaults
    .notes
        future:
        - [ ] use 'ProxyCommand'?

        see: <C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\buffer\2021-10\Proxies\.output\ProxyCommand-Create-_writeReverseHistory.ps1>
    .example
        # get my commands by default
        PS> Get-NinCommandProxy
    .example
        # else use wildcards
        PS> Get-NinCommandProxy *template* | Get-CommandSummary
    #>
    [Alias('Proxy👻.Get-Command')]
    [CmdletBinding()]
    param (
        # docstring
        [Parameter(Position = 0)]
        [string[]]$CommandName,

        # todo: future: autcomplete *only* my modules
        [Parameter()]
        [string[]]$ModuleName

    )

    begin {
        # Write-Warning 'kinda nyi / needs refactor. finds non-nin commands'
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
        ) | Sort-Object -Unique

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
