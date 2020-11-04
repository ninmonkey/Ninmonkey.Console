function Get-NinChildItem {
    <#
    .synopsis
        Less output for a nicer console experience, with useful defaults
    .description
        Defaults to showing less output, with emphasis on important information.

    .notes
    future todo:
        - [ ] pipe to 'public\Format-NinChildItemDirectory.ps1'
    #>
    [Alias('nLs')]
    param (
        [Parameter(HelpMessage = "show all")][switch]$All
    )

    begin {
        $Config = @{
            MaxFiles       = [int32]10
            MaxDirectories = [int32]10
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

        $dirList = Get-ChildItem @splatLs_Dirs
        $fileList = Get-ChildItem @splatLs_Files

        $splatJoinString_Dir.OutputSuffix = @(
            New-Text -Object (
                ' .. [ {0} Dirs ]' -f $dirList.Count
            ) -ForegroundColor 'ffffff' #$ManualColors.BrightWhite

            "`n"

        ) | Join-String

        $splatJoinString_File.OutputSuffix = @(
            New-Text -Object (
                ' .. [ {0} Files ]' -f $fileList.Count
            ) -ForegroundColor 'ffffff' #$ManualColors.BrightWhite

            "`n"

        ) | Join-String


    }
    end {
        $splatSortNewest = @{
            Descending = $true
            Property   = 'LastWriteTime'
        }
        $sortedFiles = $fileList
        | Sort-Object @splatSortNewest
        | Select-Object -First $Config.MaxFiles

        $sortedDirs = $dirList
        | Sort-Object @splatSortNewest
        | Select-Object -First $Config.MaxDirectories


        $sortedDirs
        | Join-String @splatJoinString_Dir


        $sortedFiles
        | Join-String @splatJoinString_File



        # 'List' {
        #     $sorted = $dirList | Sort-Object @splatSortNewest
        #     $sorted | Join-String -sep "`n- " -Property Name -OutputPrefix "- "
        #     break
        # }


    }


    # //System.IO.FileInfo
}
