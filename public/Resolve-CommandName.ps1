function Resolve-CommandName {
    <#
        .synopsis
            Find a command from a name or an alias
        .example
            _Resolve-Command ls | Should -eq (get-command gci)
        #>
    [CmdletBinding(PositionalBinding = $false)]
    param(
        # command/alias name
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string[]]$CommandName,

        # Error if not exactly one match is found
        [Alias('Strict')]
        [Parameter()][switch]$OneOrNone
    )
    process {
        $commands = Get-Command -Name $CommandName | ForEach-Object {
            # Get-Command -Name $_.ResolvedCommand
            if ($_.CommandType -eq 'Alias') {
                $_.ResolvedCommand
            } else {
                $_
            }
        }
        | Sort-Object -Unique -p { $_.ModuleName, $_.Name } # simple way to remove overlapping results
        if ($OneOrNone) {
            if ($commands.count -ne 1) {
                "Match count 1 != $($Commands.count)" | Write-Error
            } else {
                "Match count 1 != $($Commands.count)" | Write-Warning
            }
        }
        $Commands
    }
}
