
function Start-LogTestNet {
    param(
        [Parameter(HelpMessage = 'time to sleep between requests')]
        $DelaySeconds = 15
    )
    $FilenameSafeDate = (Get-Date).ToString("yyyy_mm_dd")
    $FileName = "PingLog_${FilenameSafeDate}.log"
    $BasePath = "$Env:UserProfile\Documents\2020\powershell\dump\log"
    $LogPath = Join-Path $BasePath -ChildPath $FileName
    $LogPath | Write-Verbose "Logging to: '$LogPath'"




    while ($true) {
        $result = Test-Net -YellowThreshold 20 -PassThru
        | Format-TestConnection
        | Export-Csv -Encoding utf8 -Path $LogPath -Append

        $result

        Start-Sleep DelaySeconds
    }
}

# Test-Net -YellowThreshold 28
# | Format-Table

# Start-LogTestNet Write-Verbose