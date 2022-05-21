#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Copy-RelativeItemTree'
    )
    $publicToExport.alias += @(
        'CopyRelativeItemTree' # 'Copy-RelativeItemTree'
    )
}

function copyRelativeItemTree {
    <#
    .SYNOPSIS
        copy items in one tree relative another, preserving any path prefix
    .DESCRIPTION
        You may filter items before piping, copy-item requires modifying relative paths
    .notes

    .LINK
        https://docs.microsoft.com/en-us/dotnet/standard/io/file-path-formats
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/System.IO.Path
    #>
    [OutputType('System.IO.FileSystemInfo', 'Object')]
    [cmdletbinding()]
    param(
        # List of items or paths to copy, allowing any pre-filters
        [Alias('Item', 'Path', 'PSPath', 'FullName')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object[]]$InputObject,

        # todo: resolvedPathMustExist (using pwsh vs dotnet paths)
        # First tree to base files on
        [Parameter(Mandatory)]
        [string]$SourceRootDir,

        # destination tree
        [Alias('BaseDest')]
        [Parameter(Mandatory)]
        [string]$DestinationRootDir,

        # return items copied: It is the same as  Copy-Item -PassThru
        [switch]$Confirm,
        # return items copied: It is the same as  Copy-Item -PassThru
        [switch]$PassThru,

        # Like -WhatIf but cleaner, output objects of what would be copied
        [switch]$TestOnly
    )
    begin {
        Write-Warning 'no WhatIf mode'
        if (!( Test-Path $SourceRootDir) -or !(Test-Path $DestinationRootDir)) {
            Throw "Source and Dest paths must exist ('$SourceRootDir', '$DestinationRootDir')"
        }
    }
    process {
        foreach ($item in $InputObject) {
            if ($null -eq $Item) {
                throw 'ShouldNeverReach: NullItem'
            }
            if (!(Test-Path $Item)) {
                throw 'ShouldNeverReach: ItemButNotExisting'

            }
            $item = Get-Item $Item # somewhere got null
            $RelativeOnly = [io.path]::GetRelativePath( $SourceRoot, $Item)
            $FullName = Join-Path $DestinationRootDir $RelativeOnly
            $DestDir = [io.path]::GetDirectoryName( $FullName )
            New-Item -Path $DestDir -ItemType Directory -Force
            $dbg = [ordered]@{
                PSTypeName       = 'copyItemDebugInfo'
                RelativeOnly     = $RelativeOnly
                FullName         = $FullName
                DestBase         = $DestinationRootDir | toEnvPath
                OriginalFullName = $Item | Get-Item | ForEach-Object FullName | toEnvPath
                SourceBase       = $SourceRootDir | toEnvPath
            }
            [pscustomobject]$Dbg | Format-List | Out-String | Write-Information
            if ($TestOnly) {
                [pscustomobject]$Dbg
                Continue
            }
            $splat = @{
                Path        = $Item
                Destination = $FullName
                Confirm     = $true
                Force       = $True
            }
            if ($PassThru) {
                $splat['PassThru'] = $PassThru
            }
            if ($Confirm) {
                $splat['PassThru'] = $Confirm
            }

            Copy-Item @splat
        }
    }
    end {
    }
}
