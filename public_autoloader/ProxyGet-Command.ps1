#Requires -Version 7



if ( $publicToExport ) {
    $publicToExport.function += @(
        'proxy.Get-Command'
    )
    $publicToExport.alias += @(
        'nin.Gcm.Exclude' # 'proxy.Get-Command
        'nin.Gcm' # 'proxy.Get-Command

    )
}

# future: actually make it a proxy
function proxy.Get-Command {
    <#
    .SYNOPSIS
        ignores many modules by default, making gcm cleaner, also ignores all native commands
    .NOTES
        idea: make this steppable, to get faster output

    to inspect most used:
        $Res | sort Count -Descending -Top 15
    #>
    [ALias('nin.Gcm.Exclude')]
    [CmdletBinding()]
    param(
        # [ArgumentCompletions(
       # )]
        [Parameter(Mandatory, Position = 0)]
        [string]$QueryString,


        # always exclude these
        [Parameter(Position = 1)]
        [ArgumentCompletions(
            'ADEssentials', 'AppBackgroundTask', 'AppLocker', 'AppvClient', 'Appx', 'Assert', 'AssignedAccess', 'AWS.Tools.Common', 'AWS.Tools.EC2', 'AWS.Tools.S3', 'AWS.Tools.SimpleEmail', 'BasicModuleTemplate', 'bdg_lib', 'Benchpress', 'BitLocker', 'BitsTransfer', 'BranchCache', 'BuildHelpers', 'chronometer', 'ClassExplorer', 'ConfigCI', 'ConfigDefender', 'ConfigDefenderPerformance', 'Configuration', 'Connectimo', 'DataMashup', 'dbatools', 'Defender', 'DeliveryOptimization', 'DirectAccessClientComponents', 'Dism', 'DnsClient', 'ErrorView', 'EventTracingManagement', 'EZOut', 'EzTheme', 'Fasdr', 'GetClrCallStack', 'HostComputeService', 'HostNetworkingService', 'Hyper-V', 'ILAssembler', 'ImpliedReflection', 'Indented.ChocoPackage', 'Indented.IniFile', 'Indented.Net.IP', 'Indented.ScriptAnalyzerRules', 'Indented.StubCommand', 'International', 'InvokeBuild', 'Irregular', 'iSCSI', 'ISE', 'Join-Object', 'JumpCloud', 'JumpCloud.SDK.DirectoryInsights', 'JumpCloud.SDK.V1', 'JumpCloud.SDK.V2', 'Kds', 'LanguagePackManagement', 'Microsoft.PowerShell.Archive', 'Microsoft.PowerShell.ConsoleGuiTools', 'Microsoft.PowerShell.Crescendo', 'Microsoft.PowerShell.Diagnostics', 'Microsoft.PowerShell.Host', 'Microsoft.PowerShell.LocalAccounts', 'Microsoft.PowerShell.ODataUtils', 'Microsoft.PowerShell.SecretManagement', 'Microsoft.PowerShell.TextUtility', 'Microsoft.PowerShell.WhatsNew', 'MMAgent', 'ModuleBuild', 'ModuleBuilder', 'MsDtc', 'NetAdapter', 'NetConnection', 'NetDiagnostics', 'NetEventPacketCapture', 'NetLbfo', 'NetNat', 'NetQos', 'NetSecurity', 'NetSwitchTeam', 'NetTCPIP', 'NetworkConnectivityStatus', 'NetworkSwitchManager', 'NetworkTransition', 'Pansies', 'PcsvDevice', 'PersistentMemory', 'Pester', 'Piecemeal', 'PipeScript', 'PKI', 'Plaster', 'platyPS', 'PnpDevice', 'posh-git', 'Posh-SSH', 'PoshInteractive', 'PoshNmap', 'PowerBIPS', 'PowerBIPS.Tools', 'PowerHTML', 'powershell-yaml', 'PowerShellAI', 'PowerShellBuild', 'PowerShellEditorServices', 'PowerShellEditorServices.Commands', 'PowerShellEditorServices.VSCode', 'PowerShellHumanizer', 'PowerShellNotebook', 'PowerShellPivot', 'PrintManagement', 'ProcessMitigations', 'Profiler', 'Provisioning', 'psake', 'PSConfig', 'PSDesiredStateConfiguration', 'PSDiagnostics', 'PSDiscord', 'PSEventViewer', 'PSFramework', 'PSFunctionInfo', 'PSFzf', 'PSKoans', 'PSLambda', 'PSLeap', 'PSModuleDevelopment', 'PSparklines', 'PSParseHTML', 'PSProfiler', 'PSReadLine', 'PSScheduledJob', 'PSScriptAnalyzer', 'PSScriptTools', 'PSStringTemplate', 'PSTree', 'PSWinDocumentation', 'PSWinDocumentation.AD', 'PSWinDocumentation.AWS', 'PSWinDocumentation.O365', 'PSWindowsUpdate', 'PSWorkflow', 'PSWorkflowUtility', 'PSWriteColor', 'PSWriteExcel', 'PSWriteHTML', 'PSWriteOffice', 'PSWriteWord', 'Revoke-Obfuscation', 'ScheduledTasks', 'ScriptBlockDisassembler', 'SecureBoot', 'Selenium', 'ShowPSAst', 'ShowUI', 'SmbShare', 'SmbWitness', 'Splatter', 'StartLayout', 'Storage', 'StorageBusCache', 'Stucco', 'SysInternals', 'Terminal-Icons', 'TerminalBlocks', 'Theme.PowerShell', 'Theme.PSReadLine', 'Theme.PSStyle', 'ThreadJob', 'TLS', 'TroubleshootingPack', 'TrustedPlatformModule', 'ugit', 'VpnClient', 'Wdac', 'Whea', 'WindowsDeveloperLicense', 'WindowsErrorReporting', 'WindowsSearch', 'WindowsUpdate', 'WindowsUpdateProvider', 'WTToolBox', 'ZLocation'
        )]
        [string[]]$ExcludeAdditionalModules, # todo: completer, which allows for alias mappings /w extra properties on completion items


        # Always Include these
        [Parameter(Position = 2)]
        [ArgumentCompletions(
                # todo: completer, which completes valid module names
                # and by categories

          'ADEssentials', 'AppBackgroundTask', 'AppLocker', 'AppvClient', 'Appx', 'Assert', 'AssignedAccess', 'AWS.Tools.Common', 'AWS.Tools.EC2', 'AWS.Tools.S3', 'AWS.Tools.SimpleEmail', 'BasicModuleTemplate', 'bdg_lib', 'Benchpress', 'BitLocker', 'BitsTransfer', 'BranchCache', 'BuildHelpers', 'chronometer', 'ClassExplorer', 'ConfigCI', 'ConfigDefender', 'ConfigDefenderPerformance', 'Configuration', 'Connectimo', 'DataMashup', 'dbatools', 'Defender', 'DeliveryOptimization', 'DirectAccessClientComponents', 'Dism', 'DnsClient', 'ErrorView', 'EventTracingManagement', 'EZOut', 'EzTheme', 'Fasdr', 'GetClrCallStack', 'HostComputeService', 'HostNetworkingService', 'Hyper-V', 'ILAssembler', 'ImpliedReflection', 'Indented.ChocoPackage', 'Indented.IniFile', 'Indented.Net.IP', 'Indented.ScriptAnalyzerRules', 'Indented.StubCommand', 'International', 'InvokeBuild', 'Irregular', 'iSCSI', 'ISE', 'Join-Object', 'JumpCloud', 'JumpCloud.SDK.DirectoryInsights', 'JumpCloud.SDK.V1', 'JumpCloud.SDK.V2', 'Kds', 'LanguagePackManagement', 'Microsoft.PowerShell.Archive', 'Microsoft.PowerShell.ConsoleGuiTools', 'Microsoft.PowerShell.Crescendo', 'Microsoft.PowerShell.Diagnostics', 'Microsoft.PowerShell.Host', 'Microsoft.PowerShell.LocalAccounts', 'Microsoft.PowerShell.ODataUtils', 'Microsoft.PowerShell.SecretManagement', 'Microsoft.PowerShell.TextUtility', 'Microsoft.PowerShell.WhatsNew', 'MMAgent', 'ModuleBuild', 'ModuleBuilder', 'MsDtc', 'NetAdapter', 'NetConnection', 'NetDiagnostics', 'NetEventPacketCapture', 'NetLbfo', 'NetNat', 'NetQos', 'NetSecurity', 'NetSwitchTeam', 'NetTCPIP', 'NetworkConnectivityStatus', 'NetworkSwitchManager', 'NetworkTransition', 'Pansies', 'PcsvDevice', 'PersistentMemory', 'Pester', 'Piecemeal', 'PipeScript', 'PKI', 'Plaster', 'platyPS', 'PnpDevice', 'posh-git', 'Posh-SSH', 'PoshInteractive', 'PoshNmap', 'PowerBIPS', 'PowerBIPS.Tools', 'PowerHTML', 'powershell-yaml', 'PowerShellAI', 'PowerShellBuild', 'PowerShellEditorServices', 'PowerShellEditorServices.Commands', 'PowerShellEditorServices.VSCode', 'PowerShellHumanizer', 'PowerShellNotebook', 'PowerShellPivot', 'PrintManagement', 'ProcessMitigations', 'Profiler', 'Provisioning', 'psake', 'PSConfig', 'PSDesiredStateConfiguration', 'PSDiagnostics', 'PSDiscord', 'PSEventViewer', 'PSFramework', 'PSFunctionInfo', 'PSFzf', 'PSKoans', 'PSLambda', 'PSLeap', 'PSModuleDevelopment', 'PSparklines', 'PSParseHTML', 'PSProfiler', 'PSReadLine', 'PSScheduledJob', 'PSScriptAnalyzer', 'PSScriptTools', 'PSStringTemplate', 'PSTree', 'PSWinDocumentation', 'PSWinDocumentation.AD', 'PSWinDocumentation.AWS', 'PSWinDocumentation.O365', 'PSWindowsUpdate', 'PSWorkflow', 'PSWorkflowUtility', 'PSWriteColor', 'PSWriteExcel', 'PSWriteHTML', 'PSWriteOffice', 'PSWriteWord', 'Revoke-Obfuscation', 'ScheduledTasks', 'ScriptBlockDisassembler', 'SecureBoot', 'Selenium', 'ShowPSAst', 'ShowUI', 'SmbShare', 'SmbWitness', 'Splatter', 'StartLayout', 'Storage', 'StorageBusCache', 'Stucco', 'SysInternals', 'Terminal-Icons', 'TerminalBlocks', 'Theme.PowerShell', 'Theme.PSReadLine', 'Theme.PSStyle', 'ThreadJob', 'TLS', 'TroubleshootingPack', 'TrustedPlatformModule', 'ugit', 'VpnClient', 'Wdac', 'Whea', 'WindowsDeveloperLicense', 'WindowsErrorReporting', 'WindowsSearch', 'WindowsUpdate', 'WindowsUpdateProvider', 'WTToolBox', 'ZLocation'
        )]
        [string[]]$IncludeAdditionalModules,

        [hashtable]$Options
    )
    $Config = mergeHashtable -other $Options -BaseHash @{
        # IncludeModules = @()
        # ExcludeModules = @()
    }

    # whitelist
    [Collections.Generic.List[Object]]$AlwaysInclude = @(

    )
    # blacklist
    [Collections.Generic.List[Object]]$AlwaysIgnore = @(
        'AWS.Tools.Installer',
        'AWS.Tools.SimpleEmailV2',
        'BurntToast',
        'CimCmdlets',
        # 'ClassExplorer',
        'EditorServicesCommandSuite',
        'functional',
        # 'ImportExcel',
        # 'JumpCloud',
        # 'JumpCloud.SDK.V1',
        # 'JumpCloud.SDK.V2',
        'Metadata',
        'Microsoft.PowerShell.Management',
        'Microsoft.PowerShell.Security',
        'Microsoft.PowerShell.Utility',
        'Microsoft.WSMan.Management',
        # 'Ninmonkey.Console',
        'PackageManagement',
        # 'Pansies',
        # 'PowerShellEditorServices.Commands',
        # 'PowerShellEditorServices.VSCode',
        'PowerShellGet'
        # 'PSReadLine',
        # 'PSScriptTools'
    )
    if($Config.ExcludeModules) {
        $AlwaysIgnore.AddRange( $Config.ExcludeModules  )
    }
    if($Config.IncludeModules) {
        $AlwaysIgnore.AddRange( $Config.IncludeModules )
    }
    'ModulesIgnored: {0}' -f @(
        $AlwaysIgnore | sort -unique | Join.UL
    ) | write-verbose

    Get-Command -Module $QueryString -ErrorAction 'continue'
    | ?{
        $_.CommandType -ne 'Application'
    }
    | Where-Object {
        $inAlwaysInclude = @($AlwaysInclude) -contains $_.Module.Name
        $inExcludes = @($AlwaysIgnore) -notcontains $_.Module.Name
        $toKeep = $true

        if($inExcludes) {
            $toKeep = $false
        }
        if($inAlwaysInclude) {
            $toKeep = $true
        }

        'Keep?: {2}: Module: {0} | Command: {1}' -f @(
            $_.Module.Name,
            $_.Name,
            $ToKeep
        ) | write-debug
        return $ToKeep
    }
    | SOrt Module, Name

}

# nin.Gcm.Exclude 'email' -IncludeAdditionalModules AWS.Tools.SimpleEmail
write-warning "NYI: $PSCommandPath"
if($false) {
    nin.Gcm.Exclude 'email' -IncludeAdditionalModules AWS.Tools.SimpleEmail
    nin.Gcm.Exclude * -ExcludeAdditionalModules 'PowerShellGet', 'PackageManagement'
}

# proxy.Get-Command -QueryString 'set' -verbose
# nin.Gcm.Exclude *

    # [string[]]$ExcludeAdditionalModules = @( # todo: completer, which allows for alias mappings /w extra properties on completion items
        #     'ADEssentials'
        #     'AppBackgroundTask'
        #     'AppLocker'
        #     'AppvClient'
