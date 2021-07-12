
#visual test, not pester test.
$NoColor = $false

$sample = Get-Process | Select-Object -First 1
$sample | Get-StaticProperty -NoColor:$NoColor
| Sort-Object TypeName
| Format-Table TypeName, Name, value -GroupBy TypeName

Hr 4

$sample | Get-StaticProperty -NoColor:$NoColor
| Sort-Object Name
| Format-Table TypeName, Name, value
