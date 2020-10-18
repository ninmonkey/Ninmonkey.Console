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
# try {
hr 5
if ($null -eq $netTrace) {
    Write-Warning 'tracing'
    Test-Connection google.com -Traceroute -ResolveDestination
    | Tee-Object -var 'netTrace'
}

Import-Module Ninmonkey.Console -Force -ea Stop

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

h2 'net'
runTest_TypeInfo $netTrace
h2 'net end'
h1 'implicit'
$netTrace
h1 'ft'
$netTrace | Format-Table


# $formatdata = Get-FormatData -TypeName $FormatTypeName -PowerShellVersion 7.1 | Format-List