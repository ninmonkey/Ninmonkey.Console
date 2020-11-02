function Toast-LogTestNetResult {

    <#
    .synopsis
        'BurntToast' popup the results of a ping
    .notes
        todo:
        - [ ] do not show unless a minimumn ping threshold has been met
            **or** if there are packet loss
        - [ ] does it matter if th;e ping average is all sites?

    #>
    [CmdletBinding()]
    param (
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
    if (! ($measurePing.Maximum -gt $Config.MinPingWarning)) {
        Write-Debug "didn't meet threshold: $($measurePing.Maximum)"
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
