function Invoke-NativeCommand {
    <#
    .synopsis
        wrapper to both call 'Get-NativeCommand' and invoke an argument list
    .example
        PS> # Use the first 'python' in path:
        Invoke-NativeCommand 'python' -Args '--version'
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

        # native command argument list
        [Alias('Args')]
        [Parameter(Position = 1)]
        [string[]]$ArgumentList
    )

    $binCommand = Get-NativeCommand $CommandName -OneOrNone:$OneOrNone -ea Stop

    # $meta = @{
    #     binCommand   = $binCommand
    #     ArgumentList = $ArgumentList | Join-String -sep ', ' -DoubleQuote
    # }

    # $meta | Format-HashTable | Join-String -sep "`n" | Write-Debug
    # $meta | Format-HashTable -Title 'Invoke-NativeCommand' | Write-Debug

    & $binCommand @ArgumentList

}

# # works
# code --help

# # works
# Invoke-NativeCommand 'pwsh' -Args @('--help')

# # 'pops up black window, does not print the help file to console'
# Invoke-NativeCommand 'code' -Args @('--help')
