function Export-PlatformFolderPath {
    <#
        .description
            compare results of [Environment]::GetFolderPath() across different platforms and versions
    #>
    param(
        [Parameter(HelpMessage = 'Try both versions of powershell in a subprocess, otherwise defaults to using the current session '
        )][switch]$TryAll,

        [Parameter(HelpMessage = 'skip converting to json')][switch]$PassThru,
        [Parameter(HelpMessage = 'minify JSON if used')][switch]$CompressJson
    )

    $folderList = [enum]::GetNames( [System.Environment+SpecialFolder] ) | ForEach-Object {
        [pscustomobject]@{
            Name = $_;
            Path = [Environment]::GetFolderPath( $_ )
        }
    }

    $metaData = @{
        'Environment'    = $PSVersionTable | Select-Object OS, Platform, @{
            n = 'PSVersion'; e = { $_.PSVersion.tostring() }
        }
        'SpecialFolders' = $folderList
    }

    $Result = [pscustomobject]$metaData
    if ($PassThru) {
        return $Result
    }

    $splat = @{
        Compress = $CompressJson ? $true : $false
    }
    $Result | ConvertTo-Json @splat
}
