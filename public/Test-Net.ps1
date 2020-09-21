
function Test-Net {
    <#
    .description
        custom defaults which wrap test-connection pings and traceroutes
    .example
        PS> Test-Net
    #>
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = '-TargetName param of Test-Connection')]
        [string[]]$TargetName,

        [Parameter(HelpMessage = 'Unmodified results')][switch]$PassThru,
        [Parameter(HelpMessage = 'nested info')][switch]$Detailed
    )

    if ( [string]::IsNullOrEmpty( $TargetName ) ) {

        [string[]]$TargetName = 'google.com', '8.8.8.8'
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
        return
    }

    $kwargs_trace.Remove('TargetName')
    $Results = $TargetName | ForEach-Object {
        $Target = $_
        Test-Connection $Target @kwargs_trace
        | Add-Member -NotePropertyName 'Time' -NotePropertyValue (Get-Date) -PassThru

    }

    $Results | Format-TestConnection -Detailed:$Detailed
}