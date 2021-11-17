using namespace System.Collections.Generic


function Resolve-CommandName {
    <#
        .synopsis
            Resolve a Command from names or aliases
        .description
            Currently returns all types, including CommandType 'Application'
        .example
            PS> Resolve-Command 'ls'
            Get-ChildItem
        .example
            PS>  Resolve-CommandName ls, goto, at -QualifiedName

                Microsoft.PowerShell.Management\Get-ChildItem
                Ninmonkey.Console\Set-NinLocation
                Utility\Select-ObjectIndex
        .outputs
            [Management.Automation.CmdletInfo[]] or [string[]]
            zero-to-many [CmdletInfo] or other [Command] types
        #>
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([object])]
    param(
        # command/alias name
        [Alias('Name')]
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string[]]$CommandName,

        # Include exe?
        [Parameter()][Switch]$IncludeExe,

        # Returns the source and command as text, ex: 'ls' outputs: 'Microsoft.PowerShell.Management\Get-ChildItem'
        [Parameter()][switch]$QualifiedName,

        # preserves alias's original names in the output
        [Parameter()][switch]$PreserveAlias,



        # Error if not exactly one match is found
        [Alias('Strict')]
        [Parameter()][switch]$OneOrNone
    )
    begin {
        $NameList = [list[string]]::new()
    }
    process {
        $CommandName | ForEach-Object {
            # just in case. guard to prevent accidental recursion
            if ($_ -eq 'Resolve-CommandName') {
                return
            }
            $NameList.Add( $_ )
        }
    }
    end {
        $getCommandSplat = @{
            Name = $NameList
            All  = $true
        }

        $commands = Get-Command @getCommandSplat | ForEach-Object {
            # Get-Command -Name $_.ResolvedCommand
            if ($_.CommandType -eq 'Alias' -and (! $PreserveAlias)) {
                $_.ResolvedCommand
            } else {
                $_
            }
        }
        | Where-Object {
            if (! $IncludeExe ) {
                if ($_.CommandType -eq 'Application') {
                    return $false
                }
                return $true
            }
            $true
        }
        | Sort-Object -Unique -p { $_.ModuleName, $_.Name } # simple way to remove overlapping results

        if ($OneOrNone) {
            if ($commands.count -ne 1) {
                "Match count 1 != $($Commands.count)" | Write-Error
            } else {
                "Match count 1 != $($Commands.count)" | Write-Warning
            }
        }

        if ($QualifiedName) {
            # this works
            $Commands | ForEach-Object {
                '{0}\{1}' -f @( $_.Source, $_.Name )
            }
            return
        }
        $Commands
    }
}
