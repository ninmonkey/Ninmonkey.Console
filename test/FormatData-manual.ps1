function runTest {
    param(
        [Parameter(
            Mandatory, Position = 0,
            HelpMessage = "object to test format data")]
        $InputObject
    )
    hr 4
    Label ( $InputObject.GetType().FullName )
    h1 "$InputObject | format-list"
    $InputObject | Format-List
    hr
    h1 "$InputObject | format-Table"
    $InputObject | Format-Table
    hr
    h1 "$InputObject"
    $InputObject
}
# try {
hr 20
Import-Module Ninmonkey.Console -Force -ea Stop

$sampleInput = @(
    ("dsf".gettype())
    , @( 'dog', 'cat')

)

foreach ($sample in $sampleInput) {
    h2 "Test: $sample"
    runTest $sample

}

# } catch {
# throw $_
# }




# $formatdata = Get-FormatData -TypeName $FormatTypeName -PowerShellVersion 7.1 | Format-List