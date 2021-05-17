
function Start-LogTestNet {
    # better verb: Invoke-TestNetLog  ?
    param(
        # time to sleep between requests
        [Parameter()]
        [double]$DelaySeconds = 15.,

        # -TargetName param of Test-Connection
        [Parameter(Position = 0)]
        [string[]]$TargetName,

        # output filepath to current log
        [Parameter()][switch]$GetLogPath,

        # Do not print to console, no Write-Progress
        [Parameter()]
        [switch]$Silent,

        # Enable toast popups of results ?
        [Parameter()][switch]$WithToast,

        # enable write-progress status ?
        [Parameter()][switch]$WriteProgress
    )
    $FilenameSafeDate = (Get-Date).ToString("yyyy_M_dd")
    $FileName = "PingLog_${FilenameSafeDate}.csv"
    $BasePath = "$Env:UserProfile\Documents\2020\powershell\dump\log"
    $LogPath = Join-Path $BasePath -ChildPath $FileName
    [int]$NumLoops = 0
    if ( [string]::IsNullOrWhiteSpace( $TargetName ) ) {
        [string[]]$TargetName = 'google.com', '8.8.8.8', '1.1.1.1'
    }

    if ($GetLogPath) {
        $LogPath
        Label 'See also' "(wip script) <$Env:UserProfile\Documents\2021\Powershell\My_Github\Misc\TestNet-Log\fetch_logs.ps1>" | Write-Host
        return
    }
    if (! $Silent) {
        Write-Host "Logging to: '$LogPath'" -ForegroundColor Green
        $TargetName | Join-String -OutputPrefix 'Targets: ' -Separator ', ' -SingleQuote
        | Write-Host -ForegroundColor Green
    }

    $host.UI.RawUI.WindowTitle = '[TestNet]'

    while ($true) {
        $NumLoops++;

        $splat = @{
            # YellowThreshold = 20
            PassThru   = $true
            TargetName = $TargetName
        }
        $result = Test-Net @splat
        | Format-TestConnection

        $Min = $result.latency | Measure-Object -Minimum | ForEach-Object Minimum
        $Max = $result.latency | Measure-Object -Maximum | ForEach-Object Maximum
        $Average = $result.latency | Measure-Object -Average | ForEach-Object Average

        $Status = 'Loop stats: #{0}, Min = {1:n2}ms, Max = {2:n2}ms, Average = {3:n2}ms' -f (
            $NumLoops,
            $Min,
            $Max,
            $Average
        )

        if (! $Silent) {
            if ($WriteProgress) {
                Write-Progress -Activity 'Logging: Test-Net' -Id 1 -Status $Status
            } else {
                Write-Host -ForegroundColor Green $Status
            }
        }

        # $result | Export-Csv -Encoding utf8 -Path $LogPath -Append
        $result
        | Select-Object -ExcludeProperty 'Time'
        | Export-Csv -Path $LogPath -Encoding utf8 -Append


        if (! $Silent) {
            $result
            | Select-Object -ExcludeProperty 'TimeString' # to be replaced when format types is set
            | Format-Table

            Toast-LogTestNetResult
        }


        Start-Sleep $DelaySeconds
    }
}
