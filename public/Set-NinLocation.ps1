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
        🐒> Goto '-'    # normal cd history works too
        🐒> Goto '+'
    .example
        # Goto the world
        gi $PROFILE  | goto  # cd to the FileItem's path
        $Profile     | goto  # go to string's path
        gcm EditFunc | goto  # jump to function declaration
        gmo NameIt   | Goto  # go to module's folder
        [CompletionResult] | goto | # to docs for: <https://docs.microsoft.com/en-us/dotnet/api/System.Management.Automation.CompletionResult>
        goto git microsoft/powerquery-parser
        goto git@github.com:microsoft/powerquery-parser.git

        # not sure on the syntax for the next:

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
    #>

    [Alias('Goto')]
    [CmdletBinding(
        PositionalBinding = $false,
        DefaultParameterSetName = 'GoToPath')] #

    param(
        # change directory to target Directory or (even a Filename)
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Parameter(
            ParameterSetName = 'GoToPath',
            Mandatory, Position = 0,
            ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('PSPath', 'Path')]
        [object]$InputObject,
        # [object]$Path,

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

        # $UniPattern = @{
        #     Home = @(
        #         Join-Re
        #         '🏘''🏘',"`u{1f3d8}"
        #         '🏡'
        #         '🏠' # House Building
        #     )
        # }

    }
    process {
        if ($InputObject -is 'type') {
            return ($InputObject | HelpFromType.2)
        }


        # if($InputObject -is 'string') {
        #     switch($InputObject) -regex {
        #         # '^🏠$' { gi '~' }
        #         # '^home$' { gi '~' }
        #         # '~' auto
        #         default { $InputObject }
        #     }
        # }

        if ( $InputObject -match ':\d+$' ) {
            # expected input:
            # prototype\AnimateColorCycle.ps1:16
            'grep/vscode filepath detected: nyi: use regex' | Write-Warning
            return
        }
        if (
            ($InputObject -match ( Ninmonkey.Console\ConvertTo-RegexLiteral -Text 'git@github.com:')) -or
            ($inputobject -match ( '\.git$' )) ) {
            'git detected: wip use regex' | Write-Warning
            return
            # git@github.com:microsoft/powerquery-parser.git

        }
        #  microsoft/powerquery-parser.git') {




        # prevent ansi color errors
        $Path = $InputObject | StripAnsi
        Write-Debug "Path: '$Path'"
        if ( [String]::IsNullOrWhiteSpace($Path) ) {
            Write-Debug 'Path: Was null or empty'
            return
        }

        # todo: wip:
        if ($false -and 'UseTheseToResolve') {
            <#
                [CompletionResult] | HelpFromType.2 -PassThru

                # Gogo the world
                gi $PROFILE  | goto  # cd to the FileItem's path
                $Profile     | goto  # go to string's path
                gcm EditFunc | goto  # jump to function declaration
                gmo NameIt   | Goto  # go to module's folder
                [CompletionResult] | goto | #

            #>
            $query_cmd = Get-Command ls -ea ignore
            $orig_obj = (Get-Command ls)
            $x = (Get-Command ls) -is 'scriptblock'
            $x = (Get-Command ls) -is 'commandinfo'
            $x | HelpFromType.2 -PassThru
            $x | editFunc -PassThru
            Resolve->Cmd $x

        }

        if ($Path -in @('-', '+')) {
            Push-Location $Path @StackName
            return
        }

        if ($Back) {
            try {
                Pop-Location -StackName 'NinLocation' -ea Stop
            }
            catch {
                Write-Debug 'stack was empty'
            }
            return
        }

        try {
            $DestItem = Get-Item $Path -ea stop
        }
        catch {
            #             Get-Item: C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github\ninmonkey.console\public\Set-NinLocation.ps1:173:34
            # Line |
            #  173 |              $DestItem = Get-Item ($path | Split-Path )
            #      |                                   ~~~~~~~~~~~~~~~~~~~~~
            #      | Cannot bind argument to parameter 'Path' because it is an empty string.
            # Set-NinLocation: Non-filesystem providers are not supported
            Write-Warning "Trying Parent, Path '$Path' did not Resolve: $_ . Did shellIntegration break prompt?"
            $DestItem = Get-Item ($path | Split-Path )
        }
        $DestItem.PSPovider.Name | Join-String -op 'provider: ' | Write-Debug
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

        Push-Location -Path $DestItem @stackname -PassThru
        | Label 'push -> ' | Write-Information


        if ($AlwaysLsAfter) {
            Ninmonkey.Console\Get-NinChildItem
        }
        return

    }
}
