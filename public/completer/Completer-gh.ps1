﻿# optionally add autocomplete for 'gh' (git hub cli)
try {
    $commandGH = Get-Command -ErrorAction Stop 'gh.exe' -CommandType Application
}
catch {
    Write-Warning "Completer: gh.exe: Did not find 'gh.exe' in path"
    return
}

$PathExport = '~/.ninmonkey/completers/gh.ps1'
if (! (Test-Path $pathExport)) {
    New-Item -ItemType File -Path $pathExport -Value '' -Force
}
$PathExport = Get-Item '~/.ninmonkey/completers/gh.ps1'

& $commandGH @(
    'completion'
    '--shell'
    'powershell'
)
| Set-Content -Path $pathExport

Write-Debug "Saved completer: gh.exe: to: '$PathExport'"
#todo: this is not
. $PathExport
Write-Debug 'loaded completer: gh.exe'
