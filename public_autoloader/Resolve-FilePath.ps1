#Requires -Version 7
using namespace System.Collections.Generic

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Resolve-FileInfo'
    )
    $publicToExport.alias += @(
        'GetItem?', # 'Resolve-FilePath'
        'Resolve-ItemInfo', # 'Resolve-FIlePath'
        'Resolve->FilePath' # 'Resolve-FilePath'
        # 'resolvePath', # 'Resolve-FilePath'
    )
}

function Resolve-FileInfo {
    <#
    .synopsis
        Resolve to paths, non-existing paths still return an object (either IO.FileInfo) always returns at least a string,  skip types that normally return null
    .example
        # Resolve-FilePath '.output' -BasePath $AppRoot
        Resolve-FilePath '.output'

                [io.fileinfo](gi Fg:\Green)
    .DESCRIPTION
        If Item doesn't exist, (or is a different provider) it attempts, in order:
            - Get-Item
            - [IO.FileSystemInfo] - works when files do not exist
            - [String] - fallback to initial input, never returns $null

    .link
        https://docs.microsoft.com/en-us/dotnet/standard/io/file-path-formats#unc-paths
    .link
        Dev.Nin\Set-ProjectRelativePath
    .link
        Dev.Nin\Resolve-ProjectRelativePath
    .link
        Ninmonkey.Console\Resolve-Path
    #>
    [Alias(
        'GetItem?',
        'Resolve-ItemInfo',
        'resolvePath',
        'Resolve->FilePath',
        'Resolve->Path'
        # 'Resolve-Item', # too broad? ?
        # 'to->FilePath' #  ?
    )]
    [OutputType(
        '[System.IO.FileSystemInfo]', '[object]', '[string]'
    )]
    [CmdletBinding()]
    param(
        [Alias('PSPath', 'Path', 'Fullname')]
        [Parameter(
            Mandatory,
            ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object]$InputObject,

        [Alias('ErrorIgnore', 'Silent')]
        [switch]$EaIgnore

        # kwargs
        # [Parameter()][hashtable]$Options
    )
    begin {
        # $Config = Ninmonkey.Console\Join-Hashtable $Config ($Options ?? @{})
    }
    process {
        $err = $Null
        $splatIgnore = @{}
        if ($EaIgnore) {
            $ErrorActionPreference = 'Ignore'
        }

        if ($EaIgnore) {
            $splatIgnore = @{ 'ErrorAction' = 'Ignore' }
        }

        [string]$OriginalName = $InputObject

        $Item = Get-Item $InputObject -ErrorVariable 'err' @splatIgnore
        if ( -not $Err ) {
            return $item
        }

        Write-Verbose "Item Path '$InputObject' does not exist, now coercing to [IO.FileInfo] from '$InputObject'"
        try {
            $item = [IO.FileInfo]$InputObject
            return $item
        } catch {
            Write-Verbose "Item Path '$InputObject' failed to coerce as [IO.FIleInfo], returning original string: '$OriginalName'"
        }

        return $OriginalName
    }

}
