
# try {
# run cached generated ones?
$CompleterPath = @{
    # todo: convert to module loader with metadata
    'gh'     = '~/.ninmonkey/completers/gh.ps1'
    'rg'     = '~/.ninmonkey/completers/rg.ps1'
    'dotnet' = '~/.ninmonkey/completers/dotnet.ps1'
    'rustup' = '~/.ninmonkey/completers/rustup.ps1'
}

# optionally add autocomplete for 'gh' (git hub cli)
& {
    # update/ Generate completers
    $rg_choco = Get-ChildItem -ea ignore $Env:ChocolateyInstall\lib\ripgrep -Recurse _rg.ps1 | Select-Object -First 1
    if ($rg_choco) {
        Write-Debug '[v] completer ⟹ generate: rg' #//⟹
        Copy-Item $rg_choco -Destination $CompleterPath.rg
    }
    else {
        Write-Warning "[w] completer ⟹ generate: rg Did not find ripgrep's '_rg.ps1' in  `$Env:ChocolateyInstall\lib\ripgrep"
    }
    if (Get-NativeCommand -TestAny 'rustup') {
        Write-Debug '[v] completer ⟹ generate: rustup' #//⟹
        & rustup @(
            'completions'
            'powershell'
        ) | Set-Content -Path $CompleterPath.rustup -Encoding utf8
    }

    if (Get-NativeCommand -TestAny 'gh') {
        Write-Debug '[v] completer ⟹ generate: gh' #//⟹
        & gh @(
            'completion'
            '--shell'
            'powershell'
        ) | Set-Content -Path $CompleterPath.gh
        # rustup completions powershell
        # | Set-Content -Path $CompleterPath.rustup -Encoding utf8
    }
    # $commandGH = Get-Command -ErrorAction Stop 'gh.exe' -CommandType Application

}
& {
    # run completers.

    # optionally add autocomplete for 'ripgrep',
    $CompleterPath.GetEnumerator() | ForEach-Object {
        Write-Debug "[v] completer ⟹ loading: $($_.Key)" #//⟹
        try {
            . $_.Value
        }
        catch {
            Write-Error $_
        }
    }



    # if ($rg_completer) {
    #     Write-Debug '🐒completer ⟹ load: ripgrep' #//⟹
    #     . $rg_completer
    # }

    # if ($autocomplete) {
    #     . $autocomplete
    # }
    # else {
    #     Write-Warning "Completer: Ripgrep: Did not find ripgrep's '_rg.ps1' in  `$Env:ChocolateyInstall\lib\ripgrep"
    # }
    # Write-Debug 'loaded completer: rg.exe'


}
# }
# catch {
#     Write-Error $_
# }
