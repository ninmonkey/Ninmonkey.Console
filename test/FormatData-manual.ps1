Import-Module Ninmonkey.Console -Force
$ti = "dsf".gettype()

hr 4
h1 '$ti | format-list'
$ti | Format-List
hr
h1 '$ti | format-Table'
$ti | Format-Table
hr
h1 '$ti'
$ti

# $formatdata = Get-FormatData -TypeName $FormatTypeName -PowerShellVersion 7.1 | Format-List