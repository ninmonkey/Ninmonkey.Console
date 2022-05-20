using namespace System.Collections.Generic

#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.variable += @(
        'ninLastPath' # from: 'Ninmonkey.Console\Resolve-FilePath'
    )
    $publicToExport.function += @(
        'Resolve-FilePath'
    )
    $publicToExport.alias += @(
        # 'sdf' # 'Resolve-FilePath'
        'GetItem?', # 'Resolve-FilePath'
        'resolvePath', # 'Resolve-FilePath'
        'Resolve->FilePath' # 'Resolve-FilePath'
    )
}


# do me -> nin.console
function Resolve-FilePath {
    <#
    .synopsis
        Resolve to paths, always returns at least a string,  skip types that normally return null

    .example
        Resolve-FilePath '.output'

        [io.fileinfo](gi Fg:\Green)

        # Resolve-FilePath '.output' -BasePath $AppRoot
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
        # 'Resolve-Item', # too broad? ?
        'resolvePath',
        # 'Resolve->Path',
        'Resolve->FilePath'
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
            # Position = 0,
            ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Name

        # [parameter()]
        # [string]$BasePath,

        # kwargs
        # [Parameter()]
        # [hashtable]$Options
    )
    begin {
        # [hashtable]$Config = @{
        #     BasePath = $BasePath ?? $App.Root ?? (Get-Item . -ea ignore) ?? '.'
        # }
        # $Config = Join-Hashtable $Config ($Options ?? @{})
    }
    process {
        [string]$OriginalName = $Name
        try {
            $item = Get-Item -ea stop $Name -ErrorVariable 'grab'
            return $item
        } catch {
            Write-Debug "Path did not exist, coercing to type: '$Name'"
        }

        try {
            $item = [IO.FileInfo]$Name
            return $item
        } catch {
            Write-Debug "Path failed to coerce as [IO.FileInfo], coercing to next type: '$Name'"
        }

        return $OriginalName
    }

}
