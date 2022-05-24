#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-FdFind'
    )
    $publicToExport.alias += @(
        'FdNin' # 'Invoke-FdFind'
    )
}
# new

function Invoke-FdFind {
    <#
        .synopsis
            .
        .notes

        ## using: .fdignore, .gitignore, and .ignore

            https://github.com/sharkdp/fd#excluding-specific-files-or-directories

            See more: https://github.com/sharkdp/fd#how-to-use

        .example
            PS> Invoke-FdFind
        .LINK
            https://github.com/sharkdp/fd
        .LINK
            https://github.com/sharkdp/fd#excluding-specific-files-or-directories

        #>
    # [outputtype( [string[]] )]
    [Alias('FdNin')]
    [cmdletbinding()]
    param(
        # docs
        # [Alias('y')]
        [parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject,

        # extra options
        [Parameter()][hashtable]$Options = @{},

        # Show expected command, but do nothing
        [Parameter()][switch]$WhatIf
    )
    begin {
        [hashtable]$Config = Join-Hashtable $Config ($Options.ColorType ?? @{})
        $Config = Join-Hashtable $Config ($Options ?? @{})
        $BinFd = Get-Command -CommandType Application 'fd'
        Write-Warning 'add custom Attr, to enable parameters but tag them as not implemented, and not crash unless used. <https://github.com/sharkdp/fd#excluding-specific-files-or-directories>'
    }
    process {
        $FdArgs = @()

        if ( $Whatif ) {
            $FdArgs | Join-String -op 'FdFind ' -sep ' '
            return
        }
        & $BinFd @FdArgs

    }
    end {
    }
}
