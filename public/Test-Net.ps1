
function Test-Net {
    <#
    .description
        custom defaults which wrap test-connection pings and traceroutes
    .example
        PS> Test-Net
    .notes
        todo:
            [ ] color dump per-line instead
            [ ] formatter for high ping values on default formatter
    #>
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = '-TargetName param of Test-Connection')]
        [string[]]$TargetName,

        [Parameter(
            HelpMessage = 'minimum value before turning yellow')]
        [int]$YellowThreshold = 40,

        [Parameter(
            HelpMessage = 'minimum value before turning yellow')]
        [int]$RedThreshold = 60,

        [Parameter(HelpMessage = 'Output results below YellowThreshold')][switch]$HideNormal,
        [Parameter(HelpMessage = 'Unmodified results')][switch]$PassThru,

        [Parameter(HelpMessage = 'nested info')][switch]$Detailed
    )

    $Config = @{
        ShowGood   = !$HideNormal
        ShowYellow = $true
        ShowRed    = $true
    }

    if ( [string]::IsNullOrEmpty( $TargetName ) ) {
        [string[]]$TargetName = 'google.com', '8.8.8.8', '1.1.1.1'
    }
    $kwargs_trace = @{
        # TargetName         = 'youtube.com', '1.1.1.1' # def: none, FromPipeline
        TargetName         = $TargetName
        ResolveDestination = $true
        MaxHops            = 128  # def: 128
        Count              = 2 # def 4
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

    if ($PassThru) {
        Test-Connection @kwargs_trace
        | Add-Member -NotePropertyName 'Time' -NotePropertyValue (Get-Date) -PassThru
        return
    }

    $kwargs_trace.Remove('TargetName')
    $Results = $TargetName | ForEach-Object {
        $Target = $_
        Test-Connection $Target @kwargs_trace
        | Add-Member -NotePropertyName 'Time' -NotePropertyValue (Get-Date) -PassThru

    }

    if ($Config.ShowGood) {
        $Results
        | Format-TestConnection -Detailed:$Detailed
    }

    # $Results | Format-TestConnection -Detailed:$Detailed


    if ($Config.ShowYellow) {
        $Results
        | Where-Object { $_.Latency -gt $YellowThreshold }
        | Format-TestConnection -Detailed:$Detailed
        | Format-Table | Out-String | Write-Host -ForegroundColor Yellow
    }
    if ($Config.ShowRed) {
        $Results
        | Where-Object { $_.Latency -gt $RedThreshold }
        | Format-TestConnection -Detailed:$Detailed
        | Format-Table | Out-String | Write-Host -ForegroundColor Red
    }

    # "`e[0m"


}

Test-Net -TargetName 1.1.1.1 | Tee-Object -var psyes