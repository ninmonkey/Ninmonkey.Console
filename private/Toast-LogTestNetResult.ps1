function Toast-LogTestNetResult {

    <#
    .synopsis
        'BurntToast' popup the results of a ping
    .notes
        todo:
        - [ ] $shouldSkip = False if
            csv | ? Status -ne 'Success'

        - []  does it matter if the ping average is on all sites?

    #>
    [CmdletBinding()]
    param (
        [Parameter(HelpMessage = "Force Popup for testing")]
        [switch]$Force
    )

    $Config = @{
        MinPingWarning = 80
    }
    $TimeFormatString = 'h:m tt' # equal to 't'
    $logPath = Start-LogTestNet -GetLogPath | Get-Item -ea Stop

    $Config | Format-Table | Out-String -Width 99999
    | Write-Debug


    $log = Import-Csv -Path $logPath | Where-Object Latency -Match '\d+'
    $latest = $log | Select-Object -Last 10 # -Wait # is wait required? probably not

    $latest | Format-Table | Out-String -Width 9999 | Write-Debug

    # $lastTC = Test-Connection google.com


    $measurePing = $latest | Measure-Object -Maximum -Minimum -Average -prop Latency

    $shouldIgnore = $true
    $maxMs = $measurePing.Maximum
    $minMs = $measurePing.Minimum
    if ($maxMs -gt $Config.MinPingWarning) {
        $shouldIgnore = $false
    }
    if ($minMs -eq 0 -or $Null -eq $minMs) {
        $shouldIgnore = $false
    }

    if ($Force) {
        $shouldIgnore = $false
    }
    if ($shouldIgnore) {
        Write-Warning @"
didn't meet threshold: $($measurePing.Maximum)
        minMs: $MinMs  , maxMs = $MaxMs
"@
        return
    }

    # $TimeString = (
    #     $latest | Select-Object -First 1 TimeString
    # ).ToString( $TimeFormatString )

    $TimeString = @($latest)[0].TimeString -as 'datetime'
    $TimeString = $TimeString.ToString($TimeFormatString)

    $template = @'
From: {0}
Max: {1}
Min: {2}
Avg: {3}
'@

    $ToastText = $template -f (
        $TimeString,
        $measurePing.Maximum,
        $measurePing.Minimum,
        $measurePing.Average
    )

    $ToastText | Write-Debug
    New-BurntToastNotification -Text $ToastText
}
