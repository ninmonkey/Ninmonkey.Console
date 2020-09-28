Write-Warning "nyi: implement: C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\public\Get-NinNamedPath.ps1"
function Get-NinNamedDotfile {
    <#
    .description
        returns path to user specific paths and log files, to make cross-platform profile usage easier
    .notes
        the future will allow user/machine specific overrides when they vary from the default
    #>
    $DotfilePath = @{
        <#
        (The path is the same for at least WPS5 and PS7)
        Join-Path $Env:APPDATA -ChildPath 'Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt'
        #>
        'Powershell History' = (Get-PSReadLineOption).HistorySavePath
        'bat'                = "$Env:USERPROFILE\Documents\2020\dotfiles_git\bat\bat.config"
        'ripgrep'            = "$Env:USERPROFILE\Documents\2020\dotfiles_git\ripgrep\.ripgreprc"
    }

}
function Get-NinNamedPath {
    <#
    .description
        returns path to user specific paths and log files, to make cross-platform profile usage easier
    .notes
        the future will allow user/machine specific overrides when they vary from the default
    #>
    param()
    Write-Warning "Todo: Clone logic from 'Get-NinNamedDotfile'"

    $DotfilePath = @{
        <#
        (The path is the same for at least WPS5 and PS7)
        Join-Path $Env:APPDATA -ChildPath 'Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt'
        #>
        'Powershell History' = (Get-PSReadLineOption).HistorySavePath



    }

}

function Get-NinNamedLog {
    <#
    .description
        returns path to user specific paths and log files, to make cross-platform profile usage easier
    .notes
        the future will allow user/machine specific overrides when they vary from the default
    #>
    Write-Warning "Todo: Clone logic from 'Get-NinNamedDotfile'"

}
