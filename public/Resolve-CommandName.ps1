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
            [nin.QualifiedCommand[]] or [CommandInfo] or [AliasInfo]
            [Management.Automation.CmdletInfo[]] or [string[]]
            zero-to-many [CmdletInfo] or other [Command] types
        .link
            Dev.Nin\ResCmd
        .link
            Dev.Nin\cmdToFilepath
        .link
            Ninmonkey.Console\Resolve-CommandName
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
        [Parameter()][switch]$OneOrNone,

        # disabled by default for speed
        [Parameter()][switch]$IncludeAll,

        # is there any point to use passthrough?
        # disabling it as a soft-deletion
        [parameter()][switch]$PassThru
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
        if ($PassThru) {
            Write-Warning 'is now obsolete?'
        }
        $getCommandSplat = @{
            Name = $NameList
            All  = $IncludeAll
        }

        <#
    warning/todo/bug:
        passing wildcard arguments get weird errors

            gcm '*find*' | rescmd -QualifiedName -PreserveAlias
    #>
        $commands = Get-Command @getCommandSplat | ForEach-Object {
            # Get-Command -Name $_.ResolvedCommand
            # if ($_.CommandType -eq 'Alias' -and (! $PreserveAlias)) {
            if ($_.CommandType -eq 'Alias') {
                $_.ResolvedCommand
                if ($PreserveAlias) {
                    $_
                }
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
        # | Sort-Object -p { $_.ModuleName, $_.Name } # simple way to remove overlapping results
        | Sort-Object -Unique -p { $_.ModuleName, $_.Name } # simple way to remove overlapping results

        if ($OneOrNone) {
            if ($commands.count -ne 1) {
                "Match count 1 != $($Commands.count)" | Write-Error
            } else {
                "Match count 1 != $($Commands.count)" | Write-Warning
            }
        }

        # refactor command
        # if (!(Test-IsNotBlank $Source)) {
        #     $Source = $cmd.Source
        # }
        # $Source = $cmd.Source

        # make tostring be itself
        if ($QualifiedName) {
            $Commands | ForEach-Object -ea continue {
                $cmd = $_
                $source = if ($cmd -is 'Management.Automation.AliasInfo') {
                    $cmd | ForEach-Object ResolvedCommand | ForEach-Object Module | ForEach-Object Name
                } else {
                    # $cnds[2] -is 'functioninfo'
                    $cmd.Source
                }

                $meta = [ordered]@{

                    PSTypeName = 'nin.QualifiedCommand'
                    Name       = '{0}\{1}' -f @(
                        $cmd.ModuleName
                        $cmd.Name
                    )
                    BaseName   = $cmd.Name
                    Source     = $Source
                    # $cmd.
                    # $cmd.comm
                }
                [pscustomobject]$meta

            }
            return
        }

        # else
        $Commands
    }

}
