```ps1
Format-NativeCommandArguments 'code' '--goto', 'someFile.log:242'

$clargs = @('--goto', (gi '..\README.md'))
$clargs | Format-NativeCommandArguments 'code'

get-date | sc 'temp:\now.txt'
sleep 0.01
get-date | sc 'temp:\now with spaces.txt'

$vscodeDiff = @(
    '--reuse-window'
    '--diff'
    gi 'temp:\now.txt'
    gi 'temp:\now with spaces.txt'
)

Format-NativeCommandArguments 'code' $vscodeDiff
```