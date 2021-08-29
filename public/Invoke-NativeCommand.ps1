
function Invoke-NativeCommand {
    <#
    .link
        Get-NativeCommand
    .link
        https://github.com/ninmonkey/Ninmonkey.Console/blob/master/help/Get-NativeCommand.md
    .synopsis
        Wrapper to both call 'Get-NativeCommand' and invoke with an argument list.
    .description
        This is about equivalent to
            $binCommand = Get-NativeCommand $Name -OneOrNone
            & $binCommand @ArgumentList

        future: for an alternate implementation that redirects STDOUT and STDERR, check out
            [Indented-Automation: Invoke-NativeCommand](https://gist.github.com/indented-automation/fba795c43ef5a53483398cdc72ab7fa0)

        also see:
           [Posh-Git\Invoke-Utf8ConsoleCommand](https://github.com/dahlbyk/posh-git/blob/b79c2dc39c9387847642bc3b38fa2186b29f6113/src/Utils.ps1#L28)

    .example
        PS> # Use the first 'python' in path:
        Invoke-NativeCommand 'python' -Args '--version'
        # Error: OneOrNone: Multiple results for 'python'. -Debug for details).
        # First was: '$env:LOCALAPPDATA\Programs\Python\Python37-32\python.exe'

    .example
        # OneOrNone will error on ambigious matches, like 'python' which has multiple versions in $Env:PATH
        Invoke-NativeCommand 'python' -OneOrNone -Args '--version'

        # runs first result
        Invoke-NativeCommand 'python' -Args '--version'
        # Python 3.7.3

        Invoke-NativeCommand python -args '--version' -Debug
        # DEBUG: Using Item: '$env:LOCALAPPDATA\Programs\Python\Python37-32\python.exe'
        # Python 3.7.3
    .notes
        Not sure if this is a a bug or not. currently this creats a new window:
            Invoke-NativeCommand 'code' -ArgumentList @('--help')
    #>
    [cmdletbinding(PositionalBinding = $false)]
    param(
        # command name: 'python' 'ping.exe', extension is optional
        [Parameter(Mandatory, Position = 0)]
        [string]$CommandName,

        # Force error if multiple  binaries are found
        [Parameter()][switch]$OneOrNone,

        # Some commands don't print STDOUT to the STDOUT stream, so they print to host if not redirected
        [Parameter()][switch]$RedirectToStdout,

        # Force error if multiple  binaries are found
        [Parameter()][switch]$WhatIf,

        # native command argument list
        [Alias('Args')]
        [Parameter(Position = 1)]
        [string[]]$ArgumentList
    )

    $binCommand = Get-NativeCommand $CommandName -OneOrNone:$OneOrNone -ea Stop
    if ($WhatIf) {
        $ArgumentList
        | Join-String -sep ' ' -op "$binCommand"
        return
    }


    <#
    future: Also needs to capture any terminating errors.
    currently running this command requires redirection to capture any output
    but that causes it to throw during an ErrorAction -stop
    NativeCommand has the same problem.

        autorunsc64 /? *>&1
    #>
    if (! $RedirectToStdout) {
        & $binCommand @ArgumentList
        return
    }
    & $binCommand @ArgumentList *>&1

}
