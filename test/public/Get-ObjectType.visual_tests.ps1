$t = New-Text -fg blue 'hi world'
# Import-Module Ninmonkey.Console -Force
#. 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\public\Get-ObjectType.ps1'

'Layout formats'

hr; $t | ForEach-Object gettype
hr; $t | TypeOf -Format
hr; $t | TypeOf -Detail
hr; $t | TypeOf -FormatMode Table
hr; $t | TypeOf -FormatMode Table -Detail
hr; $t = New-Text -fg blue 'hi world'
