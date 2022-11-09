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
enum FDFindFiletype {

}

$__paramMapping = @(
    @{
        # // converttoClassStruct
        'ShortName'       = '-H'
        'LongName'        = '--hidden'
        'HumanizedName'   = 'ShowHiddenFiles'
        'Description'     = 'Include Hidden Files'
        'LongDescription' = 'Include hidden directories and files in the search results (default: hidden files and directories are
            skipped). Files and directories are considered to be hidden if their name starts with a `.` sign (dot). The
            flag can be overridden with --no-hidden.'
        'SeeAlso'         = @(
            '--no-hidden'
        )
    }
)

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
        .example
            ($SavedPaths.GetEnumerator() | ? Key -match 'Pwsh|powershell' | % value)
|            %{ $_ | Join-String -op '--search-path=' -DoubleQuote -os '' { $_}
}
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
