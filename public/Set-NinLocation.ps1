
function Set-NinLocation {
    <#
    .Synopsis
        A nicer 'cd' command that doesn't error when the target is a filename
    .example
        PS> Goto './folder'
            # runs: cd './folder'

            # piping works
            Start-LogTestNet -GetLogPath | Goto

        PS> Goto '/folder/foo.txt'
            # runs: cd './folder'

        PS> Goto -Back
            # runs: pop-location -StackName 'NinLocation'
    #>

    [Alias('Goto')]
    [CmdletBinding(DefaultParameterSetName = 'GoToPath')]

    param(
        # change directory to target Directory or (even a Filename)
        [Parameter(
            ParameterSetName = 'GoToPath',
            Mandatory, Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [Alias('PSPath')]
        [String]$Path,

        # Go back? (uses Pop-Location on custom stack name)
        [Parameter(ParameterSetName = 'GoBack')]
        [Switch]$Back,

        # Always run 'pwd' after changing directory?
        [Alias('AlwaysGci')]
        [Parameter()][switch]$AlwaysLsAfter
    )

    $Regex = @{
        RegistryProviderPrefix = [regex]::Escape('Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\')
    }


    Write-Debug "Path: '$Path'"

    if ($Back) {
        try {
            Pop-Location -StackName 'NinLocation' -ea Stop
        } catch {
            Write-Debug 'stack was empty'
        }
        return
    }

    $DestItem = Get-Item $Path
    # need to rewrite to support registry provider
    if ($Path.PSPath -match $Regex.RegistryProviderPrefix) {
        throw 'registry'
    }
    if ($DestItem.PSProvider.Name -eq 'Registry') {

    }
    if (! (Test-Path -Path $Path)) {
        'Invalid path: {0}' -f $Path | Write-Error
        return
    }


    # $cust = 'Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' -replace (), 'HKCU:\'
    # Microsoft.PowerShell.Core\Registry::HKEY_CURRENT_USER\Keyboard Layout\



    if (!(Test-IsDirectory $DestItem.FullName)) {
        Write-Debug "Input was a file: $DestItem"
        $DestItem = $DestItem.Directory
    }

    Write-Debug "Moving to: $DestItem"
    Push-Location -Path $DestItem -StackName 'NinLocation'

    if ($AlwaysLsAfter) {
        Get-NinChildItem
    }
}

<#
temp test
Set-Location -Path 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console'
# $NowTry:
$pathToFile = Get-ChildItem -File | Select-Object -First 1

Set-NinLocation $pathToFile -Debug
Set-Location -Path 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console'
#>