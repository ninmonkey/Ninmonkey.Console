
function Start-LogTestNet {
    param(
        [Parameter(HelpMessage = 'time to sleep between requests')]
        [double]$DelaySeconds = 15.,

        [parameter(
            HelpMessage = 'output filepath to current log'
        )][switch]$GetLogPath,

        [parameter(
            HelpMessage = 'Do not print to console, no Write-Progress'
        )][switch]$Silent
    )
    $FilenameSafeDate = (Get-Date).ToString("yyyy_mm_dd")
    $FileName = "PingLog_${FilenameSafeDate}.log"
    $BasePath = "$Env:UserProfile\Documents\2020\powershell\dump\log"
    $LogPath = Join-Path $BasePath -ChildPath $FileName
    [int]$NumLoops = 0
    if ($GetLogPath) {
        Get-Item $LogPath
        return
    }
    if (! $Silent) {
        Write-Host "Logging to: '$LogPath'" -ForegroundColor Green
    }

    while ($true) {
        $Status = "Loops = $NumLoops, Min = 1, Max = 20, Average = 44"
        Write-Progress -Activity 'Logging: Test-Net' -Id 1 -Status $Status
        $result = Test-Net -YellowThreshold 20 -PassThru
        | Format-TestConnection

        $result | Export-Csv -Encoding utf8 -Path $LogPath -Append

        if (! $Silent) {
            $result | Format-Table
        }

        $NumLoops++;
        Start-Sleep $DelaySeconds
    }
}

# Test-Net -YellowThreshold 28
# | Format-Table

# Start-LogTestNet -DelaySeconds 0.3