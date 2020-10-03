
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
    param([string]$ProfileName = 'ninmonkey')
    ipython.exe --profile=${ProfileName}
}