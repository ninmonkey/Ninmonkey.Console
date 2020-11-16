& {
    # optionally add autocomplete for 'ripgrep',
    $autocomplete = Get-ChildItem $Env:ChocolateyInstall\lib\ripgrep -Recurse _rg.ps1 | Select-Object -First 1
    if ($autocomplete) {
        . $autocomplete
    } else {
        Write-Warning "Completer: Ripgrep: Did not find ripgrep's '_rg.ps1' in  `$Env:ChocolateyInstall\lib\ripgrep"
    }
    Write-Debug 'loaded completer: rg.exe'
}