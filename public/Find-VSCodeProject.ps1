function Find-GitRepo {
    <#
    .synopsis
        find folders with git repos, like 'Get-ChildItem'
    .notes
        or should it be named like get-childitem?
        future:
            a custom attribute for (filepath must exist) vs (filepath optionally exists) logic?
    .example
        PS> LsGit
    .example
        PS> LsGit 'c:\' -Depth 1

    #>
    [Alias('LsGit')]
    param(
        # root path to search
        [parameter(Position = 0)]
        [string]$Path = '.',

        # Max depth
        [parameter(Position = 1)]
        [uint]$Depth



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

    Get-ChildItem @split_gciRepo -ov 'cache' | ForEach-Object Parent

    Write-Warning '
    ask
        1] why does path "c:" and "c:\" give different results

        2] why does filter allow broken on ".git", dot should not allow the match

        3] ***solution** just compare "name" -eq ".git" for a working hack, not worth filter.
    '
}


if ($false) {
# Find-GitRepo 'C:' -Depth 2
    h1 '..\..'
    Find-GitRepo '..\..'
    h1 'c:\'
    Find-GitRepo 'C:'
    # | Join-Path -ChildPath '.git' #| ? Test-Path
}
