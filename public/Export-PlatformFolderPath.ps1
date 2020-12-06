function Export-PlatformFolderPath {
    <#
        .description
            compare results of [Environment]::GetFolderPath() across different platforms and versions
    #>
    param(
        # Try both versions of powershell in a subprocess, otherwise defaults to using the current session
        [Parameter()]
        [switch]$TryAll,

        # return PSObject instead of Json ?
        [Parameter()][switch]$PassThru,

        # minify JSON ?
        [Parameter()][switch]$CompressJson
    )

    $folderList = [enum]::GetNames( [System.Environment+SpecialFolder] ) | ForEach-Object {
        [pscustomobject]@{
            Name = $_;
            Path = [Environment]::GetFolderPath( $_ )
        }
    }
    $computerInfo = try {
        Get-ComputerInfo | Select-Object 'OsName', 'OSType', 'OSVersion', 'OsArchitecture'
    } catch {
        ''
    }

    $metaData = @{
        'PSVersion'      = $PSVersionTable | Select-Object  'PSEdition', 'OS', 'Platform', @{
            n = 'PSVersion'; e = { $_.PSVersion.tostring() }
        }
        'SpecialFolders' = $folderList
        'ComputerInfo'   = $computerInfo
    }

    $Result = [pscustomobject]$metaData

    'suggested name: ' | Write-Verbose
    if ($PassThru) {
        return $Result
    }

    $splat = @{
        # = $CompressJson ? $true : $false # ps5 breaks
        # Compress = (if ($CompressJson) { $true } else { $false } )
    }
    $Result | ConvertTo-Json @splat
}
