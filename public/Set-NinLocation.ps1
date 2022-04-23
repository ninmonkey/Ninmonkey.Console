using namespace System.Management.Automation
function Set-NinLocation {
    <#
    .Synopsis
        A nicer 'cd' command that doesn't error when the target is a filename
    .example
        🐒> Goto /c/foo/bar
        /c/foo/bar

        # go back
        🐒> Goto -Back
    .example
        🐒> Goto './folder'
            # runs: cd './folder'

            # piping works
        🐒> Start-LogTestNet -GetLogPath | Goto

        🐒> Goto '/folder/foo.txt'
            # runs: cd './folder'

        🐒> Goto -Back
            # runs: pop-location -StackName 'NinLocation'
    .notes
        future
            - [ ] if exception, try resolve-VSCodePath
            - [ ] if fail, then split path
    #>

    [Alias('Goto')]
    [CmdletBinding(PositionalBinding = $false,
        DefaultParameterSetName = 'GoToPath')]

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
        [Alias('Popd')]
        [Parameter(ParameterSetName = 'GoBack')]
        [Switch]$Back,

        # Always run 'pwd' after changing directory?
        [Alias('AlwaysGci')]
        [Parameter()][switch]$AlwaysLsAfter
    )

    Write-Debug "Path: '$Path'"

    if ($Back) {
        try {
            Pop-Location -StackName 'NinLocation' -ea Stop
        } catch {
            Write-Debug 'stack was empty'
        }
        return
    }

    try {
        $DestItem = Get-Item $Path -ea stop
    } catch {
        Write-Warning "Trying Parent, Path '$Path' did not Resolve: $_ ."
        $DestItem = Get-Item ($path | Split-Path )
    }
    $DestItem.PSPovider.Name | Join-String -op 'provider: ' | Write-Debug
    # todo; maybe test that item is container, before throwing for others
    # see Test-IsDirectory
    if ($DestItem.PSProvider.Name -ne 'filesystem') {
        # I don't need to require FS,
        $PSCmdlet.WriteError(
            [ErrorRecord]::new(
                [NotSupportedException]::new('Non-filesystem providers are not supported'),
                'InvalidProviderType',
                [ErrorCategory]::NotImplemented, $DestItem
            )
        )
        return
        # todo: future: pass command to Push-Location for providers like registry
    }

    if (! (Test-Path -Path $Path)) {
        'Invalid path: {0}' -f $Path | Write-Error -Category 'InvalidArgument'
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
        Ninmonkey.Console\Get-NinChildItem
    }
}
