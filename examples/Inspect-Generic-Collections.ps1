function re {
    Import-Module Ninmonkey.Console -Dis -Force -Scope Global 1>$null
}


$manyEnv = Get-ChildItem env:
$manyColor = Get-ChildItem env:
$manyFile = Get-ChildItem .. -Depth 2 | Get-Unique -OnType | Select-Object -First 3

$oneEnvRoot = Get-Item env:\
$oneEnvItem = Get-Item Env:\TEMP
$oneColor = Get-Item Fg:\red
$oneFile = Get-Item .

hr
Get-Collection $Obj
hr
return

$params = (Get-Command Get-Culture).Parameters
Get-Collection $params #| Format-List
hr
Get-Item env: | Get-Collection | Format-List


h1 '1'
$manyEnv = Get-ChildItem env:
h1 '2'
$manyColor = Get-ChildItem env:
h1 '3'

$envItem = Get-Item env:\
h1 '4'
$colorItem = Get-Item Fg:\red
$obj = Get-Item Env:\TEMP
Get-Collection $Obj
h1 '5'
