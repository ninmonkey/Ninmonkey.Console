using namespace System.Collections.Generic

function Resolve-CommandName {
    <#
        .synopsis
            Resolve a Command from names or aliases
        .description
            Currently returns all types, including CommandType 'Application'
        .example
            Resolve-Command 'ls'
        .outputs
            zero-to-many [CmdletInfo] or other [Command] types
        #>
    [CmdletBinding(PositionalBinding = $false)]
    param(
        # command/alias name
        [Alias('Name')]
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string[]]$CommandName,

        # Include exe?
        [Parameter()][Switch]$IncludeExe,

        # Error if not exactly one match is found
        [Alias('Strict')]
        [Parameter()][switch]$OneOrNone
    )
    begin {
        $NameList = [list[string]]::new()
    }
    process {
        $CommandName | ForEach-Object {
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
            if ($_.CommandType -eq 'Alias') {
                $_.ResolvedCommand
            }
            else {
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
        $Commands
    }
}
