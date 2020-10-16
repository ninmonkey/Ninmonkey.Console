
'.', '.', '.' | here

if ($false) {

    $t1 = Get-Date
    0..5 | ForEach-Object {
        explorer.exe (Get-Item .)
    }
    $t2 = ((Get-Date) - $t1).totalmilliseconds
    $t2

}
here -WhatIf -Debug
$files = Get-ChildItem .. -Directory | Select-Object -First 3
$files | here -WhatIf -Debug
$dirs = Get-ChildItem .. -Directory -Recurse
"files: $($files.count)"
"dirs: $($dirs.count)"

$dirs | Select-Object -First 2
| Invoke-Explorer -Debug

# exit
if ($false) {
    # $files = Get-ChildItem . -Recurse -File
    $files = Get-ChildItem .
    | Select-Object -First 7

    if ($true) {
        , $files | Invoke-Explorer -WhatIf
    } else {
        # ,$files | Invoke-Explorer
        Invoke-Explorer -Path $files
        hr
        , $files | Invoke-Explorer -ErrorAction Continue
        hr

    }

    if ($false) {

        # Invoke-Explorer
        # Invoke-Explorer -Path ..

        $files = Get-ChildItem .. -File
        $files = Get-ChildItem .. -Directory
        # $files | ForEach-Object { Invoke-Explorer $_ -ea stop }

    }
}