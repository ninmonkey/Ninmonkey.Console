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
<#
docs to implement


## Options
    Usage: code.exe [options][paths...]

    To read output from another program, append '-' (e.g. 'echo Hello World | code.exe -')


  -d --diff <file> <file>                    Compare two files with each
                                             other.
  -m --merge <path1> <path2> <base> <result> Perform a three-way merge by
                                             providing paths for two modified
                                             versions of a file, the common
                                             origin of both modified versions
                                             and the output file to save merge
                                             results.
  -a --add <folder>                          Add folder(s) to the last active
                                             window.
  -g --goto <file:line[:character]>          Open a file at the path on the
                                             specified line and character
                                             position.
  -n --new-window                            Force to open a new window.
  -r --reuse-window                          Force to open a file or folder in
                                             an already opened window.
  -w --wait                                  Wait for the files to be closed
                                             before returning.
  --locale <locale>                          The locale to use (e.g. en-US or
                                             zh-TW).
  --user-data-dir <dir>                      Specifies the directory that user
                                             data is kept in. Can be used to
                                             open multiple distinct instances
                                             of Code.
  --profile <settingsProfileName>            Opens the provided folder or
                                             workspace with the given profile
                                             and associates the profile with
                                             the workspace. If the profile
                                             does not exist, a new empty one
                                             is created. A folder or workspace
                                             must be provided for the profile
                                             to take effect.
  -h --help                                  Print usage.

## Extensions Management

  --extensions-dir <dir>              Set the root path for extensions.
  --list-extensions                   List the installed extensions.
  --show-versions                     Show versions of installed extensions,
                                      when using --list-extensions.
  --category <category>               Filters installed extensions by provided
                                      category, when using --list-extensions.
  --install-extension <ext-id | path> Installs or updates an extension. The
                                      argument is either an extension id or a
                                      path to a VSIX. The identifier of an
                                      extension is '${publisher}.${name}'. Use
                                      '--force' argument to update to latest
                                      version. To install a specific version
                                      provide '@${version}'. For example:
                                      'vscode.csharp@1.2.3'.
  --pre-release                       Installs the pre-release version of the
                                      extension, when using
                                      --install-extension
  --uninstall-extension <ext-id>      Uninstalls an extension.
  --enable-proposed-api <ext-id>      Enables proposed API features for
                                      extensions. Can receive one or more
                                      extension IDs to enable individually.

## Troubleshooting
    -v --version                    Print version.
    --verbose                       Print verbose output (implies --wait).
    --log <level>                   Log level to use. Default is 'info'. Allowed
                                    values are 'critical', 'error', 'warn',
                                    'info', 'debug', 'trace', 'off'. You can
                                    also configure the log level of an extension
                                    by passing extension id and log level in the
                                    following format:
                                    '${publisher}.${name}:${logLevel}'. For
                                    example: 'vscode.csharp:trace'. Can receive
                                    one or more such entries.
    -s --status                     Print process usage and diagnostics
                                    information.
    --prof-startup                  Run CPU profiler during startup.
    --disable-extensions            Disable all installed extensions.
    --disable-extension <ext-id>    Disable an extension.
    --sync <on | off>               Turn sync on or off.
    --inspect-extensions <port>     Allow debugging and profiling of extensions.
                                    Check the developer tools for the connection
                                    URI.
    --inspect-brk-extensions <port> Allow debugging and profiling of extensions
                                    with the extension host being paused after
                                    start. Check the developer tools for the
                                    connection URI.
    --disable-gpu                   Disable GPU hardware acceleration.
    --max-memory <memory>           Max memory size for a window (in Mbytes).
    --telemetry                     Shows all telemetry events which VS code
                                    collects.

#>

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
        loading custom environments far cleaner. (they can sare the with the same VsCode binary instance
        ie: no need to have manual updates /install )

    .example
        Pwsh> # See what the paths resolved to
            Invoke-VsCodeProfile -NameVEnv minimalPwshConfig -WhatIf -Verbose
    .example
        Pwsh> # See what the paths resolved to
            Invoke-VsCodeProfile -NameVEnv forTest.vscode_EditorServices -WhatIf -Verbose -Options @{ UserDataDir = "h:/env/code/label/data" ; AddonsDir = "h:/env/code/label/addons" }
    .NOTES
        future:
            - [ ] easier invoke profile to open func X

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


        [ArgumentCompletions(
            '@{ UserDataDir = "h:/env/code/label/data" ; AddonsDir = "h:/env/code/label/addons" }'
        )]
        [hashtable]$Options = @{},

        # set log level?
        [Parameter()]
        [ValidateSet('critical', 'debug', 'error', 'info', 'off', 'trace', 'warn')]
        [string]$LogLevel,

        # todo: will Open a single file
        # supports ':<int>' for line offsets
        [Alias('File')]
        [Parameter()]
        [string]$TargetFile,

        # todo: Will Open a directory using a profile
        [Alias('Dir')]
        [Parameter()]
        [string]$TargetDir

    )
    if ($TargetFile -or $TargetDir) {
        throw "Flag NYI: '$PSSCommandPath'"
    }
    $Config = Join-Hashtable -OtherHash $Options -BaseHash @{
        # PathVenvRoot = (Get-Item $VEnvRootPath -ea ignore ) ?? ()
        UserDataDir = Join-Path $VenvRootPath $NameVenv 'data' # ex: H:\env\code\env_fast\data
        AddonsDir   = Join-Path $VenvRootPath $NameVenv 'addons' # ex: H:\env\code\env_fast\addons
    }
    # if($TargetDir) {

    # }


    $COnfig | Format-Table -auto | oss | Join-String -sep "`n" | Write-Verbose

    # $user_data_dir = Join-Path 'H:\env\code\env_fast' 'data'
    # $addons_dir = Join-Path 'H:\env\code\env_fast' 'addons'
    $c_args = @(
        '--user-data-dir'
        $Config.UserDataDir | Join-String -DoubleQuote  # Don't even need ?

        '--extensions-dir'
        $Config.AddonsDir | Join-String -DoubleQuote  # Don't even need ?

        if ($LogLevel) {
            '--log'
            $LogLevel
        }

        '--profile'
        $NameVenv # | Join-String -DoubleQuote # Should spaces be valid profiles?
        # Label
        if ($TargetDir -and (Test-Path $TargetDir)) {
            '--add'
            (Get-Item $TargetDir) | Join-String -DoubleQuote  # Don't even need ?
            # was: '--add'
            # (Get-Item 'H:\data\2022') | Join-String -DoubleQuote  # Don't even need ?

        }
    )

    $c_args | Join-String -sep ' ' -op 'code.cmd args: ' { $_ } | Write-Verbose
    if ($WhatIf) {
        $c_args | Join-String -sep ' ' -op 'code.cmd args: ' { $_ }
        return
    }
    & code.cmd @c_args
}