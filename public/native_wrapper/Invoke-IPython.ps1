
function Invoke-IPython {
    <#
    .synopsis
        wrapper to auto import my profile on default
    .notes
        make position 0 = value from remaining args, profile is by name only.
        pass the rest to ipython.
    future:
        [ ] json configures default profile

    #>
    [Alias('IPython')]
    param(
        # [string]$ProfileName = 'ninmonkey'
    )

    process {

        $cmdList = Get-Command 'ipython' -CommandType Application -All
        $cmdList | Join-String -sep "`n" { $_.Name, $_.Version, $_.Source -join ', ' }
        | Write-Debug
    }
    # ipython.exe --profile=${ProfileName}
    # write-warning 'fix: use the proper  pattern with args array'
}

# Invoke-IPython --version -Debug
# Invoke-IPython --version