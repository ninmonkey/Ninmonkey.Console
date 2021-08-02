
function Find-GitRepo {
    <#
    .synopsis
        find folders with git repos, like 'Get-ChildItem'
    .notes
        or should it be named like get-childitem?
        future:
            a custom attribute for (filepath must exist) vs (filepath optionally exists) logic?

        future
            - [ ] return record with a custom view?

    .example
        PS> Find-GitRepo ~/documents/2021
    .example
        PS> LsGit 'c:\' -Depth 1
        | out-fzf | Goto

    #>
    [Alias('LsGit')]
    param(
        # root path to search
        [parameter(Position = 0)]
        [string]$Path = '.',

        # Max depth
        [parameter(Position = 1)]
        [uint]$Depth,

        # Max depth
        [parameter()][switch]$Detailed
    )

    $RootPath = Get-Item -ea stop $Path
    $split_gciRepo = @{
        Directory = $true
        Force     = $true
        Recurse   = $true
        Path      = $RootPath
        Filter    = '.git'
    }

    if ($Depth) {
        $split_gciRepo['Depth'] = $Depth
    }

    $dirs = Get-ChildItem @split_gciRepo
    # | Where-Object '.git'
    | ForEach-Object Parent
    | Sort-Object LastWriteTime -Descending

    if (!$Detailed) {
        $dirs
        return
    }

    $dirs | ForEach-Object {
        $meta = @{
            Name          = $_.Name
            Parent        = $_.Parent.Name
            FullName      = $_ # .FullName
            LastWriteTime = $_.LastWriteTime
            CreationTime  = $_.CreationTime
            # "OtherInfoFrom"  = 'Git-Posh'
        }
        [pscustomobject]$meta
    }
}
