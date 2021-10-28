
function Edit-GitConfig {
    <#
    .description
        an alias to edit global git config
    .notes
    try: ~/.gitconfig
       see a ton of git utils in: <https://github.com/dahlbyk/posh-git/blob/master/src/GitUtils.ps1>
    #>
    git config --global -e
}
