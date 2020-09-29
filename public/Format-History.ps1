function Format-History {
    <#
    .synopsis
        Pretty print history using syntax highlighting
    .description
        filters out duplicate commands
    .example
        PS> Format-History
    #>
    param(
        [Parameter(HelpMessage = 'Disable ANSI color output')][switch]$NoColor
    )
    Get-History | Sort-Object -Property CommandLine -Unique | Sort-Object Id | ForEach-Object {
        hr
        if ($NoColor) {
            $_.CommandLine
        } else {
            $_.CommandLine | pygmentize.exe -l ps1

        }
    }
}