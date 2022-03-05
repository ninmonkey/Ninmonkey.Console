
if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'New-WindowsTerminal'
    )
    $script:publicToExport.alias += @(
        'wt->NewTab' # 'New-WindowsTerminal'
    )
}


function New-WindowsTerminal {
    <#
    .synopsis
        super minimal, quick sugar to launch another instance using my starting directory
    .notes
        better name?

        # 'wt', see: <https://docs.microsoft.com/en-us/windows/terminal/command-line-arguments?tabs=linux>
    .example
        PS> wt->NewTab
    .example
        PS> wt->NewTab -Profile 'pwsh'
    .link
        https://docs.microsoft.com/en-us/windows/terminal/command-line-arguments
    #>
    [Alias('wt->NewTab')]
    param(
        # show args, don't launch
        [parameter()]
        [switch]$WhatIf,

        [parameter()]
        [ArgumentCompletions(
            "'pwsh'",
            "'Pwsh² -Nop'",
            "'WinPS - (Normal)'",
            "'Git-Bash'",
            "'vscode_nop'",
            "'Developer PowerShell for VS 2019'",
            "'pwsh -Admin -Nop'",
            "'Pwsh² -Admin'"

        )]$Profile
    )

    [string[]]$wtArgs = @(
        if ($Profile) {
            '--profile'
            $Profile
        }


        '--startingDirectory'
        Get-Item . | ForEach-Object FullName
        | Join-String # -DoubleQuote # seems to break parsing
        '--title'

        @(
            @( '🐵', (Get-Date).ToShortTimeString() ) -join ' '
            Get-Item . | Split-Path -Leaf
        ) | str str | Join-String -sep ' ' -SingleQuote
        #  SingleQuote Same here, quoting was read as literal




    )
    $wtArgs | Join-String -op 'wt ' -sep ' ' | Write-Information
    if ($WhatIf) {
        $wtArgs | Join-String -op 'wt ' -sep ' '
        return
    }
    & 'wt' @wtArgs
    # Start-Process /-path 'wt' -args $wtArgs
    # Start-Process -path 'wt' -args $wtArgs
    #& wt @wtArgs
}
