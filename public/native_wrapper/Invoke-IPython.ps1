
function Invoke-IPython {
    <#
    .synopsis
        wrapper to auto import my profile on default
    .notes
        see also: 'Invoke-NativeCommand'

        make position 0 = value from remaining args, profile is by name only.
        pass the rest to ipython.
    future:
        [ ] json configures default profile
    .example
        PS> Invoke-IPython '--version'
    #>
    [cmdletbinding()]
    [Alias('IPython')]
    param(
        # IPython profile name
        [Parameter()]
        [string]$ProfileName = 'ninmonkey',

        # optional Args
        [Parameter(Position = 0)]
        [object[]]$ArgumentList,

        # Force error if multiple  binaries are found
        [Parameter()][switch]$OneOrNone
    )

    process {
        <#
        if custom behavior is wanted, switch to Get-NativeCommand instaed
        #>
        # $cmd
        # [object[]]$combinedArgs = $ArgumentList += @(
        #     "--profile=${ProfileName}"
        # )

        # this works:
        # PS> Invoke-NativeCommand 'ipython' -Args '--"profile=ninmonkey"', '--version'

        $cmdArgList = @()
        $cmdArgList += $ArgumentList
        $cmdArgList += "--profile=${ProfileName}"

        $splatInvokeCommand = @{
            CommandName = 'ipython'
            Args        = @('--version')
            OneOrNone   = $OneOrNone
        }
        Invoke-NativeCommand @splatInvokeCommand

        $splatInvokeCommand | Format-HashTable | Write-Debug
        # 'aa'
        # $splatInvokeCommand | Format-HashTable
        # 'aa'
        # $splatInvokeCommand | Format-HashTable -Title 'title'
        # $splatInvokeCommand | Format-HashTable -Title 't' | Write-Verbose
        # $binPy = Get-NativeCommand 'ipython'

        # $combinedArgs | Join-String -sep ' ' -SingleQuote | Write-Verbose
        # & $binPy @combinedArgs
    }
    # ipython.exe --profile=${ProfileName}
    # write-warning 'fix: use the proper  pattern with args array'
}



if ( $false ) {
    # Invoke-IPython --version -Debug
    Invoke-IPython -Verbose --version
    # Invoke-IPython -verbose --version
    Invoke-IPython -Verbose -ProfileName ninmonkey --version
    & $binPy @("--profile=ninmonkey", '--version')
}

if ($false) {
    $binPy = Get-NativeCommand ipython

    $cmdArgs = @('--version')
    & $binPy @cmdArgs

    Invoke-IPython -Verbose
}