
function Find-GitRepo {
    <#
    .synopsis
        find folders with git repos, like 'Get-ChildItem'
    .notes
        or should it be named like get-childitem?
        future:
            a custom attribute for (filepath must exist) vs (filepath optionally exists) logic?
    #>
    [Alias('LsGit')]
    param(
        # root path to search
        [parameter(Position = 0)]
        [string]$Path = '.'
    )

    $RootPath = Get-Item -ea stop $Path
    $split_gciRepo = @{
        Directory = $true
        Force     = $true
        Recurse   = $true
        Path      = $RootPath
        Filter    = '.git'
    }

    Get-ChildItem @split_gciRepo | ForEach-Object Parent
}

