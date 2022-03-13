#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-GHRepoList'
        '_enumerateGhProperty' # to test
    )
    $publicToExport.alias += @(
        'gh->RepoList' # forgive me, for my verbing naming sins
    )
}

function _enumerateGhProperty {
    <#
    .synopsis
        sugar to dynamically generate json property names
    .notes
        currently generates names from 'gh repo list'.
        I need to test what other properties
    #>
    param(
        # future: [Parameter(Position = 0)][string]$CommandName
    )
    (gh repo list --json *>&1 | Select-Object -Skip 1) -replace '\s+', ''
}

function Invoke-GhRepoList {
    <#
    .synopsis
        invokes 'gh repo list' using dynamically generated properties
    .description
        it's sugar for using json properties '--json=<propertyList>'
    .notes
        future: [ArgumentCompletions( _enumGhProperty )]
    #>
    [Alias('gh->RepoList')] # forgive me, for my verbing naming sins
    [CmdletBinding()]
    param(
        # list of strings of properties
        [Alias('Property')]
        [string[]]$selectedProps
    )

    # $ghArg = $Property -join ','
    # & 'gh' @(
    #     'repo', 'list', "--json=${ghArgs}"
    # )

    & 'gh' @(
        'repo'
        'list'
        $selectedProps | Join-String -sep ',' -op '--json='
    )
}



if (! $publicToExport) {
    # ...
    # gh implicitly uses your CWD , if you don't specify a repo
    Push-Location 'G:\2021-github-downloads\Power-BI\dfinke🧑\NameIT\'

    # You can get 'fzf' from 'choco' or: https://github.com/junegunn/fzf
    $allProperties ??= _enumerateGhProperty
    $selectedProps = $allProperties
    | Out-Fzf -MultiSelect -Layout reverse -Height 100
    # | fzf -m
    # you may replace 'fzf' with 'or 'Out-GridView -PassThru' or 'Out-Fzf'
    # | Ninmonkey.Console\Out-Fzf -MultiSelect -Layout reverse -Height 100

    Invoke-GhRepoList -prop $selectedProps
    # Invoking native apps using [1] an array,
    # and [2] Array subexpression operator --  simplifies argument formatting
    # & 'gh' @(
    #     'repo'
    #     'list'
    #     $selectedProps | Join-String -sep ',' -op '--json='
    # )
}
