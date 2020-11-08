Write-Warning @'
first todo:
    auto-ignores:
        /.git/*
    files
        *.lnk
        by class:
            exe, .js. .cs, etc.
'@

function Format-NinChildItemDirectory {
    <#
    .synopsis
        Format only folders  with nicer output
    .description
        the default mode displays on one line, by newest first

    .notes
    future todo:
        add options for:
            - [ ] use desaturated colors for folders older than 1 week ago
            - [ ] break folders into groups based on fuzzy-last-write time, like 1week, then 1month, then 3 months
            - [ ] allow results from 'ls' to come down the pipeline
    #>
    [Alias('lsd')]
    param (
        [Parameter(
            Position = 0, HelpMessage = 'format mode')]
        [ValidateSet('Line', 'List')]
        [string]$Mode = 'Line'
    )




    begin {
    }
    process {
        Write-Warning "Nyi: wip:"

        $dirList = Get-ChildItem .. -Recurse -Directory  #-Force

        # | Select-Object -First 10


    }
    end {
        $splatSortNewest = @{
            Descending = $true
            Property   = 'LastWriteTime'
        }




        switch ($Mode) {
            'Line' {
                $sorted = $dirList | Sort-Object @splatSortNewest
                $sorted | Join-String -sep ' --  ' -Property Name
                break
            }
            'List' {
                $sorted = $dirList | Sort-Object @splatSortNewest
                $sorted | Join-String -sep "`n- " -Property Name -OutputPrefix "- "
                break
            }
            default { throw "ShouldNeverReach" }
        }
    }


    # //System.IO.FileInfo
}

function Format-NinChildItemFile {
    <#
    .synopsis
        format a mixture of files and folders
    #>
    throw "nyi: format-ninchilditemDirectory"
}
function Format-NinChildItem {
    [CmdletBinding()]
    <#
    .synopsis
        format a mixture of files and folders
    #>
    param ()
    throw "nyi: format-ninchilditem"
}

# function _alias_lsn {
#     <#
#     .synopsis
#         alias to Format-NinChildItem (because aliases don't support arguments)
#     #>
#     Format-NinChildItem -Directory
# }

if ($true) {

}

# $sample = @{}
# $sample.Dir = Get-ChildItem . -Directory | Select-Object -First 1
# $sample.File = Get-ChildItem . -File | Select-Object -First 1
# $sample.All = $sample.Dir, $sample.File


# Get-ChildItem .
# Format-NinChildItem
# Format-NinChildItemDirectory
# Format-NinChildItemDirectory