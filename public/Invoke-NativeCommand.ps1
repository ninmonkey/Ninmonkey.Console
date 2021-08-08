
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

    param(
        # command name: 'python' 'ping.exe', extension is optional
        [Parameter(Mandatory, Position = 0)]
        [string]$CommandName,

        # Force error if multiple  binaries are found
        [Parameter()][switch]$OneOrNone,

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

    & $binCommand @ArgumentList

}
