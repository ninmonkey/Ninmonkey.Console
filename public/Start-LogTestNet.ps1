
function Start-LogTestNet {
    param(
        [Parameter(HelpMessage = 'time to sleep between requests')]
        [double]$DelaySeconds = 15.,

        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = '-TargetName param of Test-Connection')]
        [string[]]$TargetName,

        [parameter(
            HelpMessage = 'output filepath to current log'
        )][switch]$GetLogPath,

        [parameter(
            HelpMessage = 'Do not print to console, no Write-Progress'
        )][switch]$Silent,

        [parameter(
            HelpMessage = 'enable write-progress status'
        )][switch]$WriteProgress
    )
    $FilenameSafeDate = (Get-Date).ToString("yyyy_M_dd")
    $FileName = "PingLog_${FilenameSafeDate}.csv"
    $BasePath = "$Env:UserProfile\Documents\2020\powershell\dump\log"
    $LogPath = Join-Path $BasePath -ChildPath $FileName
    [int]$NumLoops = 0
    if ( [string]::IsNullOrEmpty( $TargetName ) ) {
        [string[]]$TargetName = 'google.com', '8.8.8.8', '1.1.1.1'
    }

    if ($GetLogPath) {
        return $LogPath
    }
    if (! $Silent) {
        Write-Host "Logging to: '$LogPath'" -ForegroundColor Green
        $TargetName | Join-String -OutputPrefix 'Targets: ' -Separator ', ' -SingleQuote
        | Write-Host -ForegroundColor Green
    }

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
        if ($WriteProgress) {
            Write-Progress -Activity 'Logging: Test-Net' -Id 1 -Status $Status
        } else {
            Write-Host -ForegroundColor Green $Status
        }

        # $result | Export-Csv -Encoding utf8 -Path $LogPath -Append
        $result
        | Select-Object -ExcludeProperty 'Time'
        | ConvertTo-Csv
        | Add-Content -Path $LogPath -Encoding utf8


        if (! $Silent) {
            $result
            | Select-Object -ExcludeProperty 'TimeString' # to be replaced when format types is set
            | Format-Table
        }


        Start-Sleep $DelaySeconds
    }
}
