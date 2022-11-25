#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Test-WhichPwshAddon'
        '_collectProcFamilyTree'
    )
    $publicToExport.alias += @(

    )
}

function envInfo.fromProcess {
    # Collect only wanted properties, drop the rest
    $Obj = $Input
    $procSplat = @{
        ErrorAction = 'ignore'
        Property    = 'CommandLine', '*descr*', '*file*', '*versiono*', 'Path', 'Name', 'Parent', 'MainModule', '*name*'
    }
    $Obj | Select-Object @procSplat
}

# dirty. needs cleanup.
<#
class PwshAddonEnvInfo {
    hidden [hashtable]$_cached = @{}
}

function New-WhichPwshAddon {
    [PwshAddonEnvInfo]
}

#>


# (ps -id $PID).Parent | Select-Object @sSplat

function _collectProcFamilyTree {
    # If not specified, uses current PID
    # future: add members without cmdlet overhead for speed
    param(
        [Parameter()]
        [Alias('InputObject')]
        [ArgumentCompletions('(ps -id $PID)')]
        [object]$InitialProcess

        # [hashtable]$Options = @{}
    )
    # $Config = mergeHashtable

    $InitialProcess ??= Get-Process -Id $PID
    $Config = @{
        MaxDepth = 10
    }

    $next = $InitialProcess
    $Depth = 0

    while ($null -ne $next) {

        $next
        | envInfo.fromProcess
        | Add-Member -NotePropertyName 'Depth' -NotePropertyValue $Depth -PassThru -Force -ea Ignore

        $next = $next.parent
        $Depth++
        if ($Depth -gt $Config.MaxDepth) { $next = $Null }
    }


}
$script:___t_wpa = @{
    familyTree = _collectProcFamilyTree -InputObject (Get-Process -Id $PID)
}
Write-Warning "mid-write: $PSCommandpath"
function __format_whichPwshAddon {
    <#
    .SYNOPSIS
        formats output from (Test-WhichPwshAddon)
    #>
    param()

    return "nyi func: __format_whichPwshAddon: $PSCommandPath"
}
function Test-WhichPwshAddon {
    <#
    .SYNOPSIS
        started as vs code only, turned into multi-environment detection and metadata summary

    .EXAMPLE
        Pwsh>   $t = Test-WhichPwshAddon
                $t.Is
    .EXAMPLE
        Pwsh>   _collectProcFamilyTree
    .notes

        maybe:

                EditorServicesRunning = if ( (Get-Module 'EditorServicesCommandSuite', 'PowerShellEditorServices.Commands', 'PowerShellEditorServices.VSCode').count -gt 2 ) {
                    'ES჻ '
                } else { }
                EditorName            = (Get-Process -Id $pid).Parent.name

            }
    .notes
        see more

        [System.Environment]
    .LINK
        Ninmonkey.Console\_collectProcFamilyTree
    .LINK
        Ninmonkey.Console\__format_whichPwshAddon
    #>

    [Alias('__find_which_pwsh_extension')]
    [CmdletBinding()]
    param(
        # string to either print to the user, or as a template for posting in bug reports
        [switch]$AsGitIssueReportString,

        [hashtable]$Options = @{}
    )
    $Config = Join-Hashtable -OtherHash $Options -BaseHash @{

    }

    $family = $script:___t_wpa.familyTree
    $EditServicesDLL = if ($PSEditor) {
        # refactor: cleaner way to regex on nullables, below, instead of on ''
        $psEditor.GetType().Assembly.Location | Get-Item -ea ignore
    }
    else { [string]::Empty }

    if($false -and 'disabled') {
        @{
            IsDbgEnabled = (get-host).DebuggerEnabled
            ListExtensionsVersions = & 'code.cmd' --list-extensions --show-versions | Select-String '(ms-vscode.power|powerquery)' -Raw | Join-String -sep "`n"
            Runspace  = (get-host).Runspace
        }
    }

    $meta = [Ordered]@{
        FamilyTree         = $family
        IsNotAnyEditor     = 'nyi: -not $PSEditor and no extensions'
        IsPSEditor         = $PSEditor
        PwshEdition_Dll    = $PSEdition.GetType().Assembly.Location | Get-Item
        EditorServices_Dll = $EditServicesDLL
        ParentName  = (Get-Process -Id $pid).Parent.name # so far: Code|WindowsTerminal, probably insiders/previews

        Is                 = [Ordered]@{
            Host = @{
                VsCode = (get-host).Name -match 'Visual Studio Code'
                DebuggerEnabled =  (get-host).DebuggerEnabled
            }
            Ivy       = 'nyi'
            Code      = (get-host).Name -match 'Visual Studio Code'
            Any       = 'nyi'
            WT        = (Get-ChildItem Env:\WT_*).count -gt 0
            WslEnv    = (Get-ChildItem Env:\WSLENV).count -gt 0
            NoProfile = ( [Environment]::GetCommandLineArgs() -join '' -match '(-nop|-noprofile)' )
            UsingProfile = ''

            Addon     = @{
                Any  = $null
                Preview = ($EditServicesDLL.FullName -match 'ms-vscode.powershell-preview') -or (
                    [Environment]::GetCommandLineArgs() -join '' -match 'ms-vscode.powershell-preview')
                Regular = ($EditServicesDLL.FullName -match 'ms-vscode.powershell') -and (
                    $EditServicesDLL.FullName -notmatch 'ms-vscode.powershell-preview' )

            }

            OSWindows = $PSVersionTable.Platform -match 'win(32|64)' -or $PSVersionTable.OS -match 'microsoft.*windows'
            # OSLinux = if ($PSVersionTable.Platform -match 'linux|ubuntu' -or $PSVersionTable.OS -match 'linux|ubuntu') {
            #     else { 'to be expanded. partially not done' }

            #     OSDocker = if ($PSVersionTable.Platform -match 'linux|ubuntu' -or $PSVersionTable.OS -match 'linux|ubuntu') {
            #         else { 'to be expanded. partially not done' }
            #     }
            Pwsh      = [ordered]@{
                Version   = $PSVersionTable.ToString()
                PSEdition = $PSVersionTable.PSEdition

            }
        }
        Environment        = [ordered]@{
            Host             = Get-Host
            # HostIsVsCode
            CommandLine      = [Environment]::CommandLine
            CurrentDirectory = [environment]::CurrentDirectory
            Extra            = [ordered]@{
                # CurrentManagedThreadId = [environment]::CurrentManagedThreadId
                CommandLineArgs        = [Environment]::GetCommandLineArgs()
                Is64BitOperatingSystem = [environment]::Is64BitOperatingSystem
                Is64BitProcess         = [environment]::Is64BitProcess
                MachineName            = [environment]::MachineName
                OSVersion              = [environment]::OSVersion
                ProcessId              = [environment]::ProcessId
                ProcessPath            = [environment]::ProcessPath
                StackTrace             = [environment]::StackTrace
                UserName               = [Environment]::UserName
                Version                = [Environment]::Version
            }
            # SpecialFolders   = @{
            #     # [Environment]::GetFolderPath()
            # }

        }
    }

    # dynamics section, that can't exist first time without vars
    $meta.Is.Addon.Any = $meta.Is.Addon.Preview -or $meta.Is.Addon.Regular
    # $meta.Is.UsingProfile = -not $meta.Is.NoProfile

    $obj = [pscustomobject]$Meta
    if($AsGitIssueReportString) {
        return (__format_whichPwshAddon $Obj)
    }

    [pscustomobject]$meta
}


