
$script:publicToExport.function += @(
    '_enumerateMyModule'
    # 'Get-NinModule'
)
$script:publicToExport.alias += @(
    'MyModule🐒'
    'MyGmo🐒'
)

function _enumerateMyModule {
    <#
    .synopsis
        internal function, when I need to 'guess' at my module names, or autocomplete them
    .description
        super inefficient, but easily catches all cases
    .example
        # Find commands From my modules
        🐒> Get-Command -Module (_enumerateMyModule)
        | Sort Source, Version | ft CommandType, Version, Source, Name


    .example
        # find all of my modules
        🐒> _enumerateMyModule | measure
        Count             : 18

        🐒> _enumerateMyModule -All -ListAvailable | measure
        Count             : 32

    .notes
        -[ ] future:
            - query non-imported modules too, but cache the query
        -[ ] todo: at least cache the get-module call
        using
            'Test-AnyTrue'
    .outputs
        [string[]] of Module names
    #>
    [Alias('MyModule🐒', 'MyGmo🐒')]
    [cmdletbinding()]
    param(
        # All? : Get-Module -All
        [Parameter()][switch]$All,

        # Slow. ListAvailable? : Get-Module -ListAvailable
        [Parameter()][switch]$ListAvailable
        # # ListAvailable? : Get-Module -ListAvailable
        # [Parameter()][switch]$Everything
    )

    # This also determins what the 'distinct' PK test is
    $final_SortOrder = @(
        @{ e = 'name'; descending = $true }
        @{ e = 'version'; desc = $true }
    )

    $getModuleSplat = @{
        Name = '*'
    }
    # todo: Maybe a Join-Hashtable, that only merges if keys are set to non-null values

    <#        @{ 'name' = '*'}
    $paramAll = $True
    $paramList = $null
    @{ 'paramAll' = $paramAll; 'paramList' = $paramList }
    Join-Hashtable $h1 $h2 -DropNullKeys
    #>

    if ($All) {
        $getModuleSplat['All'] = $True
    }
    if ($ListAvailable) {
        $getModuleSplat['ListAvailable'] = $True
    }

    $ModuleGroups = @{
        'FavModules'     = @(
            'ClassExplorer', 'EditorServicesCommandSuite',
            'Pansies', 'PowerShellEditorServices.Commands',
            'PowerShellEditorServices.VSCode', 'PSReadLine'
        )
        'MyModules'      = @(
            Get-ChildItem "$Env:UserProfile\SkyDrive\Documents\2021\Powershell\My_Github" *.psd1 -Recurse | ForEach-Object basename
            Get-ChildItem "$Env:UserProfile\SkyDrive\Documents\2021\Powershell\My_Github" *.psm1 -Recurse | ForEach-Object basename
        ) | Sort-Object -Unique

        'Others_BigList' = @(
            'ADEssentials', 'AngleParse', 'Benchpress', 'BitLocker', 'BitsTransfer', 'BranchCache', 'BuildHelpers', 'BurntToast', 'CimCmdlets', 'CompletionPredictor', 'Configuration', 'Connectimo', 'DataMashup', 'dbatools', 'Dism', 'EditorServicesCommandSuite', 'EZOut', 'Fasdr', 'functional', 'Hyper-V', 'ImpliedReflection', 'ImportExcel', 'Indented.ChocoPackage', 'Indented.Net.IP', 'Indented.ScriptAnalyzerRules', 'Indented.StubCommand', 'IntelNetCmdlets', 'InvokeBuild', 'Irregular', 'Metadata', 'Microsoft.PowerShell.Archive', 'Microsoft.PowerShell.Diagnostics', 'Microsoft.PowerShell.Host', 'Microsoft.PowerShell.LocalAccounts', 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Security', 'Microsoft.PowerShell.TextUtility', 'Microsoft.PowerShell.Utility', 'Microsoft.WSMan.Management', 'ModuleBuild', 'ModuleBuilder', 'MSOnline', 'NameIT', 'NetTCPIP', 'Pansies', 'Pester', 'Piecemeal', 'Plaster', 'platyPS', 'posh-git', 'PoshInteractive', 'PoshNmap', 'powershell-yaml', 'PowerShellBuild', 'PowerShellGet', 'PowerShellHumanizer', 'PowerShellPivot', 'Profiler', 'PSCache', 'PSConfig', 'PSEventViewer', 'PSFunctionInfo', 'PSFzf', 'PSKoans', 'PSLambda', 'PSParseHTML', 'PSProfiler', 'PSReadLine', 'PSScriptAnalyzer', 'PSScriptTools', 'PSTree', 'PSWriteColor', 'PSWriteExcel', 'PSWriteHTML', 'PSWriteWord', 'ScriptBlockDisassembler', 'Splatter', 'SQLPS', 'Stucco', 'Terminal-Icons', 'ThreadJob', 'ugit', 'ZLocation'
        )
    }

    $allModules = Get-Module @getModuleSplat
    $uniqueNames = @(
        'Dev.Nin'
        '*ninmonkey*'
        $allModules | Where-Object Name -Match 'ninmonkey' | ForEach-Object Name
        $allModules | Where-Object Author -Match 'ninmonkey' | ForEach-Object Name
        $allModules | Where-Object Author -Match 'jake\s*bolton' | ForEach-Object Name
        $allModules | Where-Object CompanyName -Match 'jake\s*bolton' | ForEach-Object Name
        $allModules | Where-Object CompanyName -Match 'corval.*group' | ForEach-Object Name
        $allModules | Where-Object Copyright -Match 'jake\s*bolton' | ForEach-Object Name
        $allModules | Where-Object Copyright -Match 'corval.*group' | ForEach-Object Name
        $allModules | Where-Object Copyright -Match '.*ninmonkey.*' | ForEach-Object Name
        'Ninmonkey.Console'
        'Ninmonkey.Factorio'
        'Ninmonkey.Powershell'
        'Ninmonkey.Power*bi'
        'Powershell.Cv'
        '*.Jake'
        'Jake.*'
    ) | Sort-Object -Unique

    # $getModuleSplat['Name'] = $uniqueNames

    $getFinalModuleSplat = @{
        All           = $false
        ListAvailable = $false
    }
    if ($All) {
        $getFinalModuleSplat['All'] = $True
    }
    if ($ListAvailable) {
        $getFinalModuleSplat['ListAvailable'] = $True
    }

    $uniqueNames | Get-Module @getFinalModuleSplat
    | Sort-Object -Unique -Prop $final_SortOrder
}
