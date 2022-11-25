if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-SpartanVsCode'
        'New-SpartanVsCodeEnvironment'
    )
    $publicToExport.alias += @(

        # 'GoCode' # 'Invoke-SpartanVsCode'

    )
}

function New-SpartanVsCodeEnvironment {
    param (
        [Parameter(Mandatory)][string]$NameOfVenv

    )
    throw 'NYI, then update: <https://github.com/PowerShell/vscode-powershell/issues/4280>'
    $QualifiedRootPath = JOin-Path  'h:\env\code_auto' $NameOfVenv
    if( -not (Test-Path )) {
        throw "Path Already Exists! $QualifiedRootPath"
    }
    # New-Item -ItemType -Directory -
    # H:\env\code
}
function Invoke-SpartanVsCode {
    <#
    .synopsis
        launch "virtualenvs" for vs code
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
    PARAM(
        [ArgumentCompletions('h:\env')]
        [Parameter()]
        [string]$VEnvRootPath = 'h:\env',


        [Parameter()]
        [ArgumentCompletions('code_fast', 'TestOf.PowerQuery', 'TestOf.PwshConsole')]
        [string]$NameVEnv = 'code_fast',

        [hashtable]$Options = @{}
    )
    $Config = Join-Hashtable -OtherHash $Options -BaseHash @{
        PathVenvRoot = Get-Item $VEnvRootPath
    }

    $Config | Format-Table -auto | Join-String -op "SpartanConfig: `n" | Write-Warning

    $user_data_dir = Join-Path 'H:\env\code\env_fast' 'data'
    $addons_dir = Join-Path 'H:\env\code\env_fast' 'addons'
    $c_args = @(
        '--extensions-dir',
        $addons_dir,
        '--user-data-dir',
        $user_data_dir,
        '--profile',
        'fast',
        '--add',
     (Get-Item $Path)
    )

    $c_args | Format-Table -auto | Join-String -op "code.cmd args: " | Write-Warning
    & code.cmd @c_args
}