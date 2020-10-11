function Set-NinLocation {


    <#
    .Synopsis
        A nicer 'cd' command that doesn't error on files
    .example
        PS> goto './folder'
            # runs: cd './folder'

        PS> goto '/folder/foo.txt'
            # runs: cd './folder'

        PS> goto -Back
            # runs: pop-location -StackName 'NinLocation'
    #>

    [CmdletBinding(DefaultParameterSetName = 'GoToPath')]

    param(
        [Parameter(
            ParameterSetName = 'GoToPath',
            Mandatory, Position = 0,
            HelpMessage = 'Directory or Filename in the directory you want')]
        [String]$Path,

        [Parameter(
            ParameterSetName = 'GoBack',
            HelpMessage = 'Go back: Pop-Location')]
        [Switch]$Back
    )

    if ($Back) {
        try {
            Pop-Location -StackName 'NinLocation' -ea Stop
        } catch {
            Write-Debug 'stack was empty'
        }
        return
    }

    if (! (Test-Path -Path $Path)) {
        'Invalid path: {0}' -f $Path | Write-Error
        return
    }

    $DestItem = Get-Item $Path
    if (!(Test-IsDirectory $DestItem.FullName)) {
        Write-Debug "Input was a file: $DestItem"
        $DestItem = $DestItem.Directory
    }

    Write-Debug "Moving to: $DestItem"
    Push-Location -Path $DestItem -StackName 'NinLocation'
}

<#
temp test
Set-Location -Path 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console'
# $NowTry:
$pathToFile = Get-ChildItem -File | Select-Object -First 1

Set-NinLocation $pathToFile -Debug
Set-Location -Path 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console'
#>