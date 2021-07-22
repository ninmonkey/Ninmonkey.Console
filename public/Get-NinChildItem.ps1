
function Get-NinChildItem {
    <#
    .synopsis
        (NOT OPTIMIZED) Less output for a nicer console experience, with useful defaults
    .description
        Defaults to showing less output, with emphasis on important information.
        One I real format types, benchmark it
    .notes
        future todo:
            - [ ] relative separator
                - [ ] FormatMode: Inline / basic:
                    📄 Dev.Nin.psm1 -- 📄 TestExplorerResults.xml -- 📄 Todo.AggressiveAliasesForRepl.md -- 📄 todo.snippets.md

                - [ ] FormatMode: Time:
                        [today] 📄 Dev.Nin.psm1 -- 📄 TestExplorerResults.xml - [this week] - 📄 Todo.AggressiveAliasesForRepl.md -[this month]- 📄 todo.snippets.md

                    - [ ] or
                        [today]
                            📄 Dev.Nin.psm1 -- 📄 TestExplorerResults.xml
                        [this week]
                            📄 Todo.AggressiveAliasesForRepl.md
                        [this month] ... [5 files]

                    - [ ] or regular LS
                        [today]
                            📄 Dev.Nin.psm1
                            📄 TestExplorerResults.xml
                        [this week]
                            📄 Todo.AggressiveAliasesForRepl.md
                        [this month]
                            ... [5 files]


            - [ ] relative separator
            - [ ] soften / gradient files based on recency
            - [ ] count remaining hidden instead of total found
            - [ ] files of attribute == hidden are displayed faded/lighter (relative cur color)
            - [ ] use '📁'
            - [ ] based on filetype, change icon: '📄'
                - [ ] optionally use icon
            - [ ] pipe to 'public\Format-NinChildItemDirectory.ps1'
    #>
    [Alias('nLs')]
    [CmdletBinding(PositionalBinding = $false)]
    param (
        # Show all?
        [Parameter()][switch]$All,

        # # Exclude Like-Patterns
        # [Parameter()]
        # [string[]]$ExcludeName,

        # MaxFiles
        [Parameter()]
        [int]$MaxFiles = 7,

        # MaxDirectories
        [Parameter()]
        [int]$MaxDirectories = 7,

        # Path (NOT OPTIMIZED)
        [Parameter(Position = 0)]
        [string]$Path
    )

    begin {
        $Config = @{
            MaxFiles                = $MaxFiles ?? 15
            MaxDirectories          = $MaxFiles ?? 15
            AlwaysIgnoreExtension   = '.lnk'
            AlwaysIgnoreDirNameLike = '.git', '.env', '.venv', 'node_modules'
        }



        $ManualColors = @{
            TermBG      = '2e3440'
            Red         = 'bf6163'
            White       = 'd8dee9'
            BrightWhite = 'eceff4' # ece9e3
            BrightBlack = '4c566a' # ansi 90
        }

        # manual colors after theme 'nin-nord'
        $ManualColors.TermBG = '2E3440'
        $ManualColors.BrightBlack = '4C566A'
        # $ManualColors.BrightBlack = '56B6C2'


        # Aliases
        $ManualColors.DarkGray = $ManualColors.BrightBlack

        $ColorDirSB = {
            $Color = $ManualColors.BrightWhite
            $Color = 'red'
            $Color = 'blue'
            $Color = '88C0D0'
            $Name = '/', $_.Name -join ''
            (New-Text -Object $Name -fore $Color).toString()
            # (New-Text -Object $_.Name -fore $ManualColors.BrightWhite).toString()
        }

    }
    process {

        if (Test-Path $Path) {
            # temp hack, because existing code assumed cwd
            # code needs a clean rewrite from scratch
            Push-Location $Path
        }
        if ($All) {
            $Config.MaxFiles = [int32]::MaxValue
            $Config.MaxDirectories = [int32]::MaxValue
        }

        $splatLs_Dirs = @{
            Recurse   = $False
            File      = $False
            Directory = $true
            Force     = $true
            Path      = '.'
        }

        $splatLs_Files = @{
            Recurse   = $False
            File      = $true
            Directory = $False
            Force     = $true
            Path      = '.'
        }

        $splatJoinString_Dir = @{
            # Separator    = ' --  '
            Separator    = New-Text ' -- ' -fg $ManualColors.DarkGray
            Property     = $ColorDirSB # $_.Name with color

            OutputPrefix = "`n"
            # OutputSuffix = " ...`n"
        }

        $splatJoinString_File = @{
            # Separator    = ',  '
            Separator    = New-Text ' -- ' -fg $ManualColors.DarkGray
            Property     = 'Name'
            OutputPrefix = '' #"`n"
            # OutputSuffix = @(
            #     New-Text '...' -fg $ManualColors.DarkGray
            #     "`n"
            # ) -join ''
        }
        $sb_RenderFilename = {
            '📄', $_.Name -join ' '
        }

        if ($true) {
            $splatJoinString_File.Property = $sb_RenderFilename
        }

        $dirList = Get-ChildItem @splatLs_Dirs | Where-Object {
            $curFile = $_
            $isKept = $true
            $Config.AlwaysIgnoreDirNameLike | ForEach-Object {
                if ($curFile.Name -like $_) {
                    $isKept = $false
                }
            }
            $isKept
        }
        $fileList = Get-ChildItem @splatLs_Files | Where-Object {
            $_.Extension -notin $Config.AlwaysIgnoreExtension
        }
        # $remaining_count = $dirList.Count - $Config.MaxDirectories
        $splatJoinString_Dir.OutputSuffix = @(
            New-Text -Object (
                ' .. [ {0} Dirs ]' -f @(
                    $dirList.count  # this is counts after filter
                )
            ) -ForegroundColor 'ffffff' #$ManualColors.BrightWhite
            "`n"
        ) | Join-String



        # $remaining_count_files =  $fileList.Count - $Config.MaxFiles
        $splatJoinString_File.OutputSuffix = @(
            New-Text -Object (
                ' .. [ {0} Files ]' -f @(
                    $fileList.count
                    # $remaining_count_files # this is counts after filter
                )
            ) -ForegroundColor 'ffffff' #$ManualColors.BrightWhite

            "`n"

        ) | Join-String

        Pop-Location

    }
    end {
        $splat_SortParam = @{
            Descending = $true
            Property   = 'LastWriteTime'
        }
        $sortedFiles = $fileList
        | Sort-Object @splat_SortParam
        | Select-Object -First $Config.MaxFiles
        # | Join-String -Property Name -sep '    ;  '

        $sortedDirs = $dirList
        | Sort-Object @splat_SortParam
        | Select-Object -First $Config.MaxDirectories


        $sortedDirs
        | Join-String @splatJoinString_Dir


        $sortedFiles
        | Join-String @splatJoinString_File
    }
}

if ($debug) {
    nls
}
