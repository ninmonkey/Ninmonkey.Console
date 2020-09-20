#"`n" * 20
$path = 'c:\'
Get-ChildItem $path  -Depth 2 -Force -ev 'error_ls' -ea SilentlyContinue| ForEach-Object { $i = 0 } {
    $i++
    $num = $i % 12
    if ($num -eq 0) {
        Write-Progress -Activity 'searching' -Status $i
    }
}

Label 'errors:' $error_ls.count