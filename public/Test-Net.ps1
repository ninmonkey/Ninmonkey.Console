﻿
function Test-Net {
    <#
    .description
        custom defaults which wrap test-connection pings and traceroutes
    .example
        PS> Test-Net
        PS> Test-Net -PassThru
        PS> Test-Net 'wikipedia.com' -YellowThreshold  30
        PS> Test-Net 'wikipedia.com' -YellowThreshold 45 -HideNormal
    .notes
        todo:
            [ ] color dump per-line instead
            [ ] formatter for high ping values on default formatter
    #>
    param(
        # -TargetName param of Test-Connection
        [Parameter(Position = 0)]
        [string[]]$TargetName,

        # minimum value before turning yellow
        [Parameter()]
        [int]$YellowThreshold = 40,

        # minimum value before turning red
        [Parameter()]
        [int]$RedThreshold = 60,

        # Hide results better than YellowThreshold ?
        [Parameter()][switch]$HideNormal,

        # unmodified results ?
        [Parameter()][switch]$PassThru,

        # for 'TestConnection -Count'
        [Parameter()][int]$Count = 2,

        # incldue nested info?
        [Parameter()][switch]$Detailed
    )

    $Config = @{
        ShowGood   = !$HideNormal
        ShowYellow = $true
        ShowRed    = $true
    }

    if ( [string]::IsNullOrEmpty( $TargetName ) ) {
        [string[]]$TargetName = 'google.com', '8.8.8.8', '1.1.1.1'
    }
    $splat_testNet = @{
        # TargetName         = 'youtube.com', '1.1.1.1' # def: none, FromPipeline
        TargetName         = $TargetName
        ResolveDestination = $true
        MaxHops            = 128  # def: 128
        Count              = 1 # Because actual iteration below uses $Count
        # IPv4               = $true  #def: false
        # IPv6               = $true  #def: false
        # Repeat = $true
        # paramset is -Count XOR -Repeat
        TimeoutSeconds     = 2 # def: 5
        # TcpPort            = 80 # default: None
        # Ping= $true
        #TraceRoute = $false
        # returns obj: TestConnectionCommand+TraceStatus
    }
    $splat_formatTest = @{
        Detailed = $Detailed
    }

    $Results = 1..$count | ForEach-Object {
        $curIter = $_
        $curResult = Test-Connection @splat_testNet
        | Add-Member -NotePropertyName 'Time' -NotePropertyValue (Get-Date) -PassThru
        | Add-Member -NotePropertyName 'TimeString' -NotePropertyValue ( (Get-Date).tostring('o') ) -PassThru

        $curResult
    }

    if ($PassThru) {
        return $Results
    }


    $Results = $Results | Select-Object -ExcludeProperty 'TimeString' # to be replaced when format types is set

    if ($Config.ShowGood) {
        $Results
        | Where-Object { $_.Latency -lt $YellowThreshold }
        | Format-TestConnection @splat_formatTest

    }

    if ($Config.ShowYellow) {
        $Results
        | Where-Object { $_.Latency -gt $YellowThreshold }
        | Format-TestConnection @splat_formatTest
        | Format-Table | Out-String | Write-Host -ForegroundColor Yellow
        # todo: # cleanup by using custom formatter
        # Then convert these to filters, not 3 outputs per color
    }
    if ($Config.ShowRed) {
        $Results
        | Where-Object { $_.Latency -gt $RedThreshold }
        | Format-TestConnection @splat_formatTest
        | Format-Table | Out-String | Write-Host -ForegroundColor Red

    }

    # "`e[0m"


}
