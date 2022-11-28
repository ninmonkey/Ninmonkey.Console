if ( $publicToExport ) {
    $publicToExport.function += @(

        'Invoke-VsCodeProfile'
        'New-SpartanVsCodeEnvironment'
    )
    $publicToExport.alias += @(
        'Invoke-SpartanVsCode' # backward compat alias, to remove next build. 'Invoke-VsCodeProfile'

        'Code-vEnv' # 'Invoke-VsCodeProfile'
        'CodeI-vEnv' # 'Invoke-VsCodeProfile'
        # extra alias to consolidate from dev.nin
        # 'Code-vEnv',
        # 'CodeI-vEnv',
        # 'Collect-VSCodeEnv',
        # 'Out-CodeIvEnv',
        # 'Out-CodevEnv'
    )
}

function New-SpartanVsCodeEnvironment {
    param (
        [Parameter(Mandatory)][string]$NameOfVenv

    )
    throw 'NYI, then update: <https://github.com/PowerShell/vscode-powershell/issues/4280>'
    $QualifiedRootPath = Join-Path 'h:\env\code_auto' $NameOfVenv
    if ( -not (Test-Path )) {
        throw "Path Already Exists! $QualifiedRootPath"
    }
    # New-Item -ItemType -Directory -
    # H:\env\code
}
function Invoke-VsCodeProfile {
    <#
    .synopsis
        launch "virtualenvs" for vs code, with their own user data dir, and addons dir
    .DESCRIPTION
        Useuful for creating minimally-reproduced test cases for error reporting
        Or, different settings when you aren't using a workspace config

        I had an older 'venv' which was hacky. New arguments make
        loading custom environments (with the same VsCode binary instance)

    .example
        Invoke-SpartanVsCode
    .example
        or shared
    .NOTES
        future:
            - [ ] resume command (vs just --adding)
            - [ ] handle paths not existing with a New-SpartanVsCodeEnvironment
            - [ ] better invocation so that STDIN can be used
            - [ ] log paths used
    #>
    [Alias(
        'Invoke-SpartanVsCode',
        # extra alias to consolidate from dev.nin
        'Code-vEnv',
        'CodeI-vEnv'
        # 'Collect-VSCodeEnv',
        # 'Out-CodeIvEnv',
        # 'Out-CodevEnv'
    )] # make alias always auto invoke mini profile?
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] # To be mandatory, or always do the mini one?
        [Alias('Label')]
        [ArgumentCompletions(
            'forTest.vscode_EditorServices',
            'forTest.vscode_PowerQuery',
            'forTest.vscode_EditorServices',
            'forTest.Pwsh_console',
            'fast_load'
            # 'TestOf.PowerQuery'
        )]
        [string]$NameVEnv = 'code_fast',

        # Root path for all 'venv'.
        # Added to $Label for FullPath

        [Parameter()]
        [Alias('EnvRoot')]
        [ArgumentCompletions(
            'h:/env/code',
            'h:/env'
        )]
        [string]$VEnvRootPath = 'h:/env/code',

        # todo: currentlyh a quick hack before ShouldProcess
        [switch]$WhatIf,



        [hashtable]$Options = @{}
    )
    $Config = Join-Hashtable -OtherHash $Options -BaseHash @{
        # PathVenvRoot = (Get-Item $VEnvRootPath -ea ignore ) ?? ()
        UserDataDir = Join-Path $VenvRootPath $NameVenv 'data' # ex: H:\env\code\env_fast\data
        AddonsDir   = Join-Path $VenvRootPath $NameVenv 'addons' # ex: H:\env\code\env_fast\addons
    }

    $COnfig | Format-Table -auto | oss | Join-String -sep "`n" | Write-Verbose

    # $user_data_dir = Join-Path 'H:\env\code\env_fast' 'data'
    # $addons_dir = Join-Path 'H:\env\code\env_fast' 'addons'
    $c_args = @(
        '--extensions-dir'
        $addons_dir | Join-String -DoubleQuote  # Don't even need ?
        '--user-data-dir'
        $user_data_dir | Join-String -DoubleQuote  # Don't even need ?
        '--profile'
        $NameVenv # Label
        '--add'
        # (Get-Item $Path) # Don't even need ?
        (Get-Item 'H:\data\2022') | Join-String -DoubleQuote  # Don't even need ?
    )

    $c_args | Format-Table -auto | Join-String -op 'code.cmd args: ' | Write-Warning
    if ($WhatIf) {
        return
    }
    & code.cmd @c_args
}