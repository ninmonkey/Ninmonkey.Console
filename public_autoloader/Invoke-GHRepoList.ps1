#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-GHRepoList'
        '_enumerateGhProperty' # to test
    )
    $publicToExport.alias += @(
        'gh->RepoList' # forgive me,  my verbing naming sins, and the += operator
    )
}

function _enumerateGhProperty {
    <#
    .synopsis
        sugar to dynamically generate '--json' property names, for api calls
    .notes
        currently generates names from 'gh repo list'.
        I need to test what other properties
    .link
        https://cli.github.com/manual/gh_repo
    .link
        Ninmonkey.Console\Out-Fzf
    #>
    # [RequiresCommandAttribute('Name' = 'gh', 'optional' = $false)] # future metadata attribute
    [CmdletBinding()]
    param(
        # future: [Parameter(Position = 0)][string]$CommandName


    )
    (gh repo list --json *>&1 | Select-Object -Skip 1) -replace '\s+', ''
}



function Invoke-GhRepoList {
    <#
    .synopsis
        invokes 'gh repo list' and  dynamically generates property names
    .description
        it's sugar for using json properties '--json <propertyList>'
    .notes
        future: [ArgumentCompletions( _enumGhProperty )]
    .link
        https://cli.github.com/manual
    .link
        Ninmonkey.Console\Out-Fzf
    .link
        Ninmonkey.Console\_enumerateGhProperty
    .link
        https://cli.github.com/manual/gh_help_formatting
    .link
        https://github.blog/2021-03-11-scripting-with-github-cli/
    #>
    # [RequiresCommandAttribute('Name' = 'gh', 'optional' = $false)] # future metadata attribute
    [Alias('gh->RepoList')] # forgive me, for my verbing naming sins
    [CmdletBinding()]
    param(
        # list of strings of property names for 'gh --json=<propList>
        [Alias('Property')]
        [Parameter(Mandatory, Position = 0)]
        [string[]]$selectedProps,

        [Alias('OwnerName')]
        [Parameter(Position = 1)]
        [ArgumentCompletions(
            'dfinke', 'EvotecIT', 'IISResetMe', 'IndentedAutomation',
            'Ninmonkey', 'Jaykul', 'JustinGrote', 'SeeminglyScience', 'StartAutomating'
        )]
        [string]$GitRepoOwner
    )

    # second: 2022-06-20 : do attribute completer
    $ghArgs = @(
        'repo'
        'list'
        if ($GitRepoOwner) {
            $GitRepoOwner # implicit, but why not be explicit
        }
        '--json'
        $selectedProps | Join-String -sep ',' -op "'" -os "'"
    )
    $ghArgs | Join-String -op 'gh ' -sep ' '
    # | label 'gh: ' | Write-Information

    & 'gh' @ghArgs
}



if ( $___debugInlineTest) {
    # example usage
    # gh implicitly uses your CWD, or else yourself --  when you don't specify an <owner>
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
