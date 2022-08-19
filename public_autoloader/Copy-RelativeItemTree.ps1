#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Copy-RelativeItemTree'
    )
    $publicToExport.alias += @(
        'CopyRelativeItemTree' # 'Copy-RelativeItemTree'
    )
}

function Copy-RelativeItemTree {
    <#
    .SYNOPSIS
        copy items in one tree relative another, preserving any path prefix
    .DESCRIPTION
        You may filter items before piping, copy-item requires modifying relative paths
    .notes
    .example
        # Recent VS Code logs
        $Results = fd --changed-within 20minutes --search-path $AppConfig.SourceRoot -t f
        | StripAnsi | Get-Item
        | Copy-RelativeItemTree -SourceRootDir $AppConfig.SourceRoot -DestinationRootDir $AppConfig.DestRoot -TestOnly -PassThru -infa ignore


    .LINK
        https://docs.microsoft.com/en-us/dotnet/standard/io/file-path-formats
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/System.IO.Path
    #>
    [Alias('CopyRelativeItemTree')]
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

        # overwrite existing files?
        # strange, it errors on copy-item but force is passed?
        # [Alias('Force')]
        # [switch]$ReplaceExisting
    )
    begin {

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
            $RelativeOnly = [io.path]::GetRelativePath( $SourceRootDir, $Item)
            $FullName = Join-Path $DestinationRootDir $RelativeOnly
            $DestDir = [io.path]::GetDirectoryName( $FullName )
            New-Item -Path $DestDir -ItemType Directory -Force | Out-Null
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
                # Confirm     = $true
                Force       = $True
            }
            if ($PassThru) {
                $splat['PassThru'] = $PassThru
            }
            if ($Confirm) {
                $splat['Confirm'] = $Confirm
            }

            Copy-Item @splat
        }
    }
    end {
    }
}
