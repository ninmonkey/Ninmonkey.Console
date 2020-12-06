
function Format-TestConnection {
    <#
    .description
        Nicer default formatting and parsing of Test-Connection results.
    .example
        PS> Test-Connection '1.1.1.1' | Format-TestConnection

    #>
    param(
        # Ping result record
        # [Microsoft.PowerShell.Commands.TestConnectionCommand+PingStatus]
        [Parameter(
            ParameterSetName = 'Ping',
            Mandatory, ValueFromPipeline, Position = 0)]
        $InputRecord,

        # extra nested information
        [Parameter()][switch]$Detailed
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

function private_Format-TestConnectionPingCommand {
    <#
    .description
        Create a nice [PSCustomObject] from a [Microsoft.PowerShell.Commands.TestConnectionCommand+PingStatus
    .notes
        move to /private if used by more modules than this single script
    .example
        PS> Test-Connection '1.1.1.1' | private_Format-TestConnectionPingCommand

    #>
    param(
        # ping records
        # [Microsoft.PowerShell.Commands.TestConnectionCommand+PingStatus[]]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        # include extra nested information
        [Parameter()][switch]$Detailed
    )

    process {

        $InputObject | ForEach-Object {

            $addr = $_.DisplayAddress
            if ($null -eq $addr) {
                $addr = $_.Address
            }

            $hash = [ordered]@{
                Source      = $_.Source
                Destination = $_.Destination
                Address     = $addr # $_.DisplayAddress
                Latency     = $_.Latency
                Status      = $_.Status

            }

            if (!($null -eq $_.Time)) {
                $hash.Time = $_.Time
            }
            if (!($null -eq $_.TimeString)) {
                $hash.TimeString = $_.TimeString
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
