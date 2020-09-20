function private_Format-TestConnectionPingCommand {
    param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'records')]
        [Microsoft.PowerShell.Commands.TestConnectionCommand+PingStatus[]]
        $InputObject,

        [Parameter(HelpMessage = 'include extra nested information')]
        [switch]$Detailed
    )

    process {

        $InputObject | ForEach-Object {
            $hash = [ordered]@{
                Source      = $_.Source
                Destination = $_.Destination
                Address     = $_.DisplayAddress
                Latency     = $_.Latency
                Status      = $_.Status

            }

            if (!($null -eq $_.Time)) {
                $hash.Time = $_.Time
            }

            if ($Detailed) {
                $hash.NestedInfo = [ordered]@{
                    Address   = $_.Address
                    PingReply = $_.Reply
                    # $hash.Op
                }

            }
        }

        [pscustomobject]$hash
    }
}

function Format-TestConnection {
    <#
    .description
        Nicer default formatting and parsing of Test-Connection results.

    #>
    param(
        [Parameter(
            ParameterSetName = 'Ping',
            Mandatory, ValueFromPipeline, Position = 0, HelpMessage = 'ping record')]
        [Microsoft.PowerShell.Commands.TestConnectionCommand+PingStatus]
        $InputRecord,

        [Parameter(HelpMessage = 'extra nested information')]
        [switch]$Detailed
    )

    <#
    maybe

        $results | ForEach-Object {
        $hash = [ordered]@{
            Source      = $_.Source
            Destination = $_.Destination
            Address     = $_.DisplayAddress
            Latency     = $_.Latency
            Status      = $_.Status

        }

        if ($Detailed) {
            $hash.NestedInfo = [ordered]@{
                Address               = $_.Address
                PingReply             = $_.Reply
                Options               = $_.Options
                $hash.NestedPingReply = $_.Reply
                $hash.Op
            }

        }
    }

    #>

    process {
        # function map

        "RecordType: $($InputRecord.GetType().FullName)" | Write-Debug

        switch ( $PSCmdlet.ParameterSetName) {
            'Ping' {
                'ping' | Write-Verbose
                $InputRecord | private_Format-TestConnectionPingCommand -Detailed:$Detailed
            }
            default {
                "Error: ParamSet: $($PSCmdlet.ParameterSetName), InputRecord type: $($InputRecord.GetType().FullName)"
            }
        }
    }
}

function Test-Net {
    <#
    .description
        custom defaults which wrap test-connection pings and traceroutes
    #>
    param(
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = '-TargetName param of Test-Connection')]
        [string[]]$TargetName,

        [Parameter(HelpMessage = 'Unmodified results')][switch]$PassThru,
        [Parameter(HelpMessage = 'nested info')][switch]$Detailed

        # [switch]$Detailed
    )
    # $calcProp = @{}
    # $calcProp.TypeSummary = @{
    #     n = 'Type'
    #     e = {
    #         $_.GetType().Name
    #     }
    # }
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
    $res = $TargetName | ForEach-Object {
        $Target = $_
        Test-Connection $Target @kwargs_trace
        | Add-Member -NotePropertyName 'Time' -NotePropertyValue (Get-Date) -PassThru

    }


    $script:preformat = $Res
    $res | Format-TestConnection -Detailed:$Detailed

    # | Format-TestConnection -Verbose -Debug
}

'test cases'
& {
    h1 'def -> FormatTestConnection -detail'
    Test-Connection google.com -Count 1 | Format-TestConnection -Detailed
    h1 'def -> FormatTestConnection'
    Test-Connection google.com -Count 1 | Format-TestConnection

    h1 'Test-Net -PassThru'
    Test-Net google.com -PassThru
    h1 'Test-Net -PassThru -Detailed'
    Test-Net google.com -PassThru -Detailed

    h1 'Test-Net -Detailed'
    Test-Net google.com -Detailed
    h1 'Test-Net'
    Test-Net google.com

}
# if ($preformat) {
#     $preformat | Format-TestConnection -Verbose -Debug
# }
Test-Net 'google.com' #-Verbose -Debug # | Select-Object *
# Write-Warning 'todo: custom format for this type''s default output as FT'

# format results
# exit
# $results = Test-Net

# $DisableCache = $false
# if ($DisableCache -or !$cachedResults) {
#     $cachedResults = Test-Net
# }
# $cachedResults | Format-TestConnection -Debug -Verbose


# Test-Connection '8.8.8.8' -Count 1 | ForEach-Object {
#     $_ | Add-Member -NotePropertyName 'TimeWas' -NotePropertyValue (Get-Date)
# # } | Select-Object *
# Test-Connection '8.8.8.8' -Count 1 | ForEach-Object {
#     $_ | Add-Member -NotePropertyName 'TimeWas' -NotePropertyValue 'now'
# } | Select-Object *