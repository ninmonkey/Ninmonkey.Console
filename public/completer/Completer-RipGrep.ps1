& {
    # optionally add autocomplete for 'ripgrep',
    $autocomplete = Get-ChildItem $Env:ChocolateyInstall\lib\ripgrep -Recurse _rg.ps1
    if ($null -eq $autocomplete) {
        Write-Warning "Completer: Ripgrep: Did not find ripgrep's '_rg.ps1' in  `$Env:ChocolateyInstall\lib\ripgrep"
    } else {
        . $autocomplete
    }
    Write-Debug 'loaded completer: rg.exe'
}