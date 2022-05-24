
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
        minimal sugar to launch another instance using my starting directory
    .notes
        PS> wt->NewTab
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
            "'pwsh'", "'Pwsh² -Nop'", "'WinPS - (Normal)'",
            "'Developer PowerShell for VS 2019'",
            "'Pwsh² -Admin'", "'pwsh -Admin -Nop'"
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
