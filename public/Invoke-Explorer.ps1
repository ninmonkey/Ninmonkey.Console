function Invoke-Explorer {
    <#
    .synopsis
        Open a folder using "explorer.exe"
    .description
        runs ShouldProcess when there are more directories than $MinWarning. Othewise silently open.
    .example
        # open current folder
        PS> Here

        # open path:
        PS> Here 'c:\foo\bar'

        # this can trigger ShouldProcess
        ls . -recurse | Here -Whatif
    .notes
        todo:
            - [ ] default to should process when dirs > 3

    #>
    [Alias('Here')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Which type[s] to find?")]
        [string[]]$Path = '.',

        [Parameter(
            HelpMessage = "Minimum number of folders that trigger confirmation")]
        [int]$MinWarning = 3
    )
    begin {
        $ValidFolders = [list[string]]::new()
    }

    process {
        $Path | ForEach-Object {
            $curItem = Get-Item $_

            if (!( Test-Path $curItem) ) {
                Write-Error "Invalid path: '$curItem'"
                continue
            }
            if (!(Test-IsDirectory -Path $curItem)) {
                Write-Error "Not a directory: '$curItem'"
                continue
            }

            $ValidFolders.Add( $curItem )
        }
    }

    end {
        Write-Debug "Found $($ValidFolders.Count) Directories"
        $ShouldWarn = $ValidFolders.Count -ge $MinWarning

        if ($ShouldWarn) {
            foreach ($folder in $ValidFolders) {
                if ($PSCmdlet.ShouldProcess($folder, 'Invoke-Explorer')) {
                    Write-Debug "Invoke-Explorer: '$folder'"
                    explorer.exe $folder
                }
            }
            return
        }

        foreach ($folder in $ValidFolders) {
            # technically this should support whatif
            # **maybe** adjust impact level of commandlet instead?
            Write-Debug "Invoke-Explorer: '$folder'"
            explorer.exe $folder
        }
    }
}
