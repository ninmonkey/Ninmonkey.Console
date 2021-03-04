Import-Module Ninmonkey.Console -Force | Out-Null
h1 'quick test'


Get-NativeCommand -List 'python'
| Select-Object Name, Source | ForEach-Object Source
hr
Get-NativeCommand bat -OneOrNone
Get-NativeCommand python -OneOrNone

h1 'test lookup'

Label 'expect multiple'
Get-NativeCommand -List python

# cached just for the test file
Label 'Select specific one'
$fzf_selection ??= Get-NativeCommand -List python | ForEach-Object Source | Out-Fzf

Label 'Now -OneOrNone'
Get-NativeCommand $fzf_selection -OneOrNone

if(Get-NativeCommand -Test '')