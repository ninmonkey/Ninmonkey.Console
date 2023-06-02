function .git.Resolve-SymbolReference {
    <#
    .synopsis
        Resolves hash from Branch names, tag names, etc. Input from ugit or native git.
    .EXAMPLE
        PS> git branch | .git.Show-Ref

    .EXAMPLE
        PS> # works with ugit
            import-module ugit -ea 'stop'
            git branch | .git.Show-Ref

            # works with native # remove-module 'ugit'
            git.exe branch | .git.Show-Ref

        SymbolName                    SymbolRef                                Name
        ----------                    ---------                                ----
        main                          8bd126b09440d830b854b25bcd810dfd3f73b3d6 refs/heads/main
        main                          100b03af01b9574b5c4a98b22fef8d7d1b659d5b refs/remotes/origin/main
        backup-test                   746193d3fb5ce30afbc6d6c927fbfe4a5dbcae57 refs/heads/backup-test
        Feature-EncodingCompleterTest e3e67251c467c51c1893724f366bd5229be2b234 refs/heads/Feature-EncodingCompleterTest
        Feature-UpdateTabCompleter    8dc80d0c09ccdb2da0f6a7bf254d85a21ae87a4e refs/heads/Feature-UpdateTabCompleter
        Feature-UpdateTabCompleter    8dc80d0c09ccdb2da0f6a7bf254d85a21ae87a4e refs/remotes/origin/Feature-UpdateTabCompleter
    #>
    [Alias('.git.Show-Ref')]
    param(
        # note: ugit pipeline input works
        # raw text from git
        [Alias('BranchName')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$SymbolName
    )
    process {
        $binGit = $ExecutionContext.InvokeCommand.GetCommand('git', 'Application') | select -first 1
        if(-not $binGit) { throw '"git" of type Application was not found'}
        # git show-ref $SymbolName
        # ugit is fine, but raw text from the user piping raw git, needs cleanup
        $SymbolName = $SymbolName -replace '\*', '' -replace '\s+', ''
        $query = & $binGit show-ref $SymbolName
        @(
            foreach ($pair in $query) {
                $hash, $name = $pair.Trim() -split '\s+'

                [pscustomobject]@{
                    PSTypeName = '.git.ResolvedReference'
                    SymbolName = $SymbolName
                    SymbolRef  = $Hash
                    Name = $Name
                }
        })
        | Sort-Object SymbolName
    }
}

$splatExport = @{
    Function = @(
        '.git.Resolve-SymbolReference' # '.git.Show-Ref'
    )
    Alias = @(
        '.git.Show-Ref' # '.git.Resolve-SymbolReference'
    )
}

Export-ModuleMember @splatExport

# $summary = @(
#     .git.Resolve-SymbolReference -SymbolName 'refs/remotes/origin/Improve-Onboarding'
#     .git.Resolve-SymbolReference -SymbolName 'main'
# )
# $summary
