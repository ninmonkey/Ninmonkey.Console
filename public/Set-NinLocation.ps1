using namespace System.Management.Automation

function Set-NinLocation {
    <#
    .Synopsis
        A nicer 'cd' command that doesn't error when the target is a filename
    .description
        calls
            Push-Location -Path $DestItem -StackName 'NinLocation'
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
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
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
    begin {
        $StackName = @{
            StackName = 'ninLocationStack'
        }

    }
    process {

        # prevent ansi color errors
        $Path = $Path | StripAnsi
        Write-Debug "Path: '$Path'"
        if ( [String]::IsNullOrWhiteSpace($Path) ) {
            Write-Debug 'Path: Was null or empty'
            return
        }

        if ($Path -in @('-', '+')) {
            Push-Location $Path @StackName
            return
        }

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

        if ($true) {

            Write-Debug "Moving to: $DestItem"

            Push-Location -Path $DestItem @stackname -PassThru
            | Label 'push -> ' | Write-Information


            if ($AlwaysLsAfter) {
                Ninmonkey.Console\Get-NinChildItem
            }
            return
        }
        # if ($True) {
        #     return
        #     # Write-Debug 'go ->'
        #     # Inspect-PathInfoStack
        #     # Write-Debug "go-> '$DestItem'"

        #     # Set-Location -StackName $null -PassThru | Label 'new stack' | Write-Information

        #     # Push-Location -Path $DestItem -StackName $null -PassThru | Label 'new push' | Write-Information
        #     # Get-Location -Stack | Label 'get-stack' | Write-Information




        #     # This snippet, from in a module,  *will* set user's default stack to the new path
        #     # the problem is that truncates it, so you only want to, if, you're not currently the current stack
        #     # H1 'starting...'

        #     # 0..4 | ForEach-Object {
        #     #     Push-Location -Path (_randPath) -PassThru | Label 'push ->'
        #     # }

        #     # Inspect-PathInfoStack
        #     # Push-Location -Path (Get-Item . ) -StackName $null -PassThru
        #     # Push-Location -Path (Get-Item '~') -StackName $null -PassThru
        #     # Get-Location -Stack

        #     return
        # }

        # if ($false) {

        #     H1 'stack?'
        #     Get-Location -Stack
        #     Hr
        #     Get-Item . | Label -fg orange 'loc='
        #     H1 'set-loc'
        #     # this worked
        #     Set-Location -StackName $null -PassThru | Label 'stack "nin"'
        #     Get-Item . | Label -fg orange 'loc='
        #     H1 'push-loc'
        #     Push-Location -Path (Get-Item .) -PassThru -StackName $null | Label 'stack2'
        #     Get-Item . | Label -fg orange 'loc='
        # }

    }
}
