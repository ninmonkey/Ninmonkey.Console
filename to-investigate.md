- <file:///C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Ninmonkey.Console\public_autoloader\Join-Hashtable.ps1>

ask
- does ExpectingInput() or input pipeline done 
- [1] allowe cleaner paramsets (or logic) ?

- [2] does 'end-of-pipeline' let you  enable smart formatting, instead of

$items = ls .
if($PassTHru) { return $items }
$items | ft -auto Name, *

more:
```ps1

$res = @( @{a = 9} ; [ordered]@{ a = 22 ; z = 4 } )
| Join-Hashtable -BaseHash @{b=5}

```