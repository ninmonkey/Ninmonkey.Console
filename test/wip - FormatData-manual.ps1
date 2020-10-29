mif ($null -eq $Cache) {
    $Cache = @{}
}
$TestConfig = @{
    'TraceIter1' = $False
    'GetType'    = $False
    'TracePing'  = $true
    'TraceRoute' = $true
}
Import-Module Ninmonkey.Console -Force -ea Stop

function runTest_TypeInfo {
    param(
        [Parameter(
            Mandatory, Position = 0,
            HelpMessage = "object to test format data")]
        $InputObject
    )
    $TypeInfo = $InputObject.GetType()

    $LabelText = '[{0}] -> [{1}]' -f @(
        $InputObject.GetType().FullName
        @($InputObject)[0].GetType().FullName
    )
    hr 4
    h1 "$InputObject | format-list"
    Label $LabelText
    $TypeInfo | Format-List

    hr
    h1 "$InputObject | format-Table"
    Label $LabelText
    $TypeInfo | Format-Table

    hr
    h1 "$InputObject"
    Label $LabelText
    $TypeInfo
}

if ($TestConfig.TraceIter1) {
    if ($null -eq $netTrace) {
        Write-Warning 'tracing'
        Test-Connection google.com -Traceroute -ResolveDestination
        | Tee-Object -var 'netTrace'
    }
}

if ($TestConfig.GetType) {
    $sampleInput = @(
        # , @( 'dog', 'cat')
        , @( 1, 5)
        "dsf"
    )

    foreach ($sample in $sampleInput) {
        h2 "Test: $sample"
        runTest_TypeInfo $sample
    }

    # } catch {
    # throw $_
    # }
}

if ($false) {
    h2 'net'
    runTest_TypeInfo $netTrace
    h2 'net end'
    h1 'implicit'
    $netTrace
    h1 'ft'
    $netTrace | Format-Table

}
if ($TestConfig.TracePing) {
    h1 'TracePing'
    if ($null -eq $Cache.TracePing) {
        Write-Warning 'Ping...'
        Test-Connection stpl-dsl-gw21.stpl.qwest.net -ResolveDestination
        | Tee-Object -Variable 'lastTracePing'
        $Cache.TracePing = $LastTracePing
    }
    $Cache.TracePing | Format-Table
}

if ($TestConfig.TraceRoute) {
    h1 'TraceRoute'
    Label 'Ft'
    if ($null -eq $Cache.TraceRoute) {
        Write-Warning 'TraceRoute...'
        Test-Connection stpl-dsl-gw21.stpl.qwest.net -ResolveDestination -Traceroute
        | Tee-Object -Variable 'lastTraceRoute'
        $Cache.TraceRoute = $LastTraceRoute
    }
    $Cache.TraceRoute | Format-Table

    # list is verbose so grab the highest ping
    Label 'Fl'
    $Cache.TraceRoute
    | Sort-Object -Property Latency -Descending
    | Select-Object -First 1 | Format-List



}

# $formatdata = Get-FormatData -TypeName $FormatTypeName -PowerShellVersion 7.1 | Format-List
<##>
