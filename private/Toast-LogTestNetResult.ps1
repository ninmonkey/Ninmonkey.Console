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

    $TimeFormatString = 'h:m tt' # equal to 't'

    $logPath = Start-LogTestNet -GetLogPath | Get-Item -ea Stop

    $log = Import-Csv -Path $logPath | Where-Object Latency -Match '\d+'
    $latest = $log | Select-Object -Last 10 # -Wait # is wait required? probably not

    $latest | Format-Table | Out-String -Width 9999 | Write-Debug

    # $lastTC = Test-Connection google.com


    $measure = $latest | Measure-Object -Maximum -Minimum -Average -prop Latency
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
        $measure.Maximum,
        $measure.Minimum,
        $measure.Average
    )

    $ToastText | Write-Debug
    New-BurntToastNotification -Text $ToastText
}
