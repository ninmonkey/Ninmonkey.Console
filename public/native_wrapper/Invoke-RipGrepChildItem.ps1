function Get-RipGrepChildItem {
    Write-Warning 'Get-RipGrepChildItem: Wip'
    # rg 'prompt' -c  | ForEach-Object { $_ -replace '\:\d+$', '' } | Tee-Object -Variable 'filelist'
    # see integration with 'Fzf'
    #         <https://github.com/junegunn/fzf#3-interactive-ripgrep-integration>

}
