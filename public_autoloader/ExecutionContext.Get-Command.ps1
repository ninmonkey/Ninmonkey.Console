using namespace System.Diagnostics.CodeAnalysis


#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Debug.ExecutionContext.Get-Command' # ''
    )
    $publicToExport.alias += @(
        # '' # 'Debug.ExecutionContext.Get-Command'
    )
    $publicToExport.variable += @(
        # '' # from: 'Ninmonkey.Console\Debug.ExecutionContext.Get-Command'
    )
}

function Debug.ExecutionContext.Get-Command {
    <#
    .SYNOPSIS
        super minimal execution context wrapper
    .example

    Debug.ExecutionContext.Get-Command '*python*' -CommandType Alias,Function | ft -AutoSize

        CommandType Name                      Version Source
        ----------- ----                      ------- ------
        Alias       IPython -> Invoke-IPython 0.2.45  ninmonkey.console

    Debug.ExecutionContext.Get-Command '*test*' -CommandType Cmdlet | Ft -AutoSize

        CommandType Name                            Version   Source
        ----------- ----                            -------   ------
        Cmdlet      Test-PSSessionConfigurationFile 7.3.4.500 Microsoft.PowerShell.Core
        Cmdlet      Test-ModuleManifest             7.3.4.500 Microsoft.PowerShell.Core
        Cmdlet      Test-Connection                 7.0.0.0   Microsoft.PowerShell.Management
        Cmdlet      Test-Path                       7.0.0.0   Microsoft.PowerShell.Management
        Cmdlet      Test-Json                       7.0.0.0   Microsoft.PowerShell.Utility
        Cmdlet      Test-FileCatalog                7.0.0.0   Microsoft.PowerShell.Security
        Cmdlet      Test-WSMan                      7.0.0.0   Microsoft.WSMan.Management

    .example
        PS> Debug.ExecutionContext.Get-Command 'gci' -CommandType 'All'
    .example
        PS> Debug.ExecutionContext.Get-Command '*help*' -CommandType All
        | Sort-Object CommandType,Name,Source| ft -AutoSize
    .NOTES
    see also:
        - [System.Management.Automation.CommandInvocationIntrinsics]
    #>
    # see: <https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.codeanalysis.suppressmessageattribute.scope?view=net-7.0#system-diagnostics-codeanalysis-suppressmessageattribute-scope>
    # [SuppressMessage('PSUseApprovedVerbs', '')]
    param(
        [Alias('InputObject')]
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 0)]
        [string[]]$CommandName,


        # if it doesn't autocomplete, then
        # [ArgumentCompletions(
        #     "'All'", "'Alias,Function'",
        #     'Alias', 'All', 'Application', 'Cmdlet', 'Configuration', 'ExternalScript', 'Filter', 'Function', 'Script', 'value__'
        #         )]
        [Parameter(Position = 1)]
        [Management.Automation.CommandTypes]$CommandType = ([Management.Automation.CommandTypes]::All),

        [Alias('WithoutPattern')]
        [switch]$ExactMatchOnly
    )
    $CommandName | ForEach-Object {
        $curCommandName = $_

        ' => ExecutionContext => GetCommand: [ name: {0}, type: {1} ]' -f @(
            $curCommandName -join ', '
            $CommandType -join ', '
        ) | Write-Verbose

        if ($ExactMatchOnly) {
            $query =
            $ExecutionContext.InvokeCommand.GetCommand(
                <# commandName: #> $curCommandName,
                <# type: #>        $commandType )
        }
        else {
            $nameIsPattern = $true
            $Query =
            $ExecutionContext.InvokeCommand.GetCommands(
                <# name: #>          $curCommandName,
                <# commandTypes: #>  $commandType,
                <# nameIsPattern: #> $nameIsPattern )
        }
        $query
    }
}
