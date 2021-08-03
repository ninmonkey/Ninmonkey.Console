# This is the entry point for auto completers
$CompleterPath = @{
    # todo: convert to module loader with metadata
    'gh'     = '~/.ninmonkey/completers/gh.ps1'
    'rg'     = '~/.ninmonkey/completers/rg.ps1'
    # 'dotnet' = '~/.ninmonkey/completers/dotnet.ps1' # there is no automatic one
    'rustup' = '~/.ninmonkey/completers/rustup.ps1'
}
function Build-CustomCompleter {
    <#
    .synopsis
        internal. This Imports native commands that have powershell completers
    .description
        Generate (maybe cached)
    .example
        PS> Build-CustomCompleter
    .link
        Import-CustomCompleter
    .link
        Import-GeneratedCompleter

    #>

    [cmdletbinding()]
    param()
    # internal use
    # try {
    # run cached generated ones?

    # optionally add autocomplete for 'gh' (git hub cli)
    # & {
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
        Invoke-NativeCommand -ea stop 'rustup' -ArgumentList @(
            'completions'
            'powershell'
        ) | Set-Content  -Path $CompleterPath.rustup -Encoding utf8
        # & rustup @(
        # ) | Set-Content -Path $CompleterPath.rustup -Encoding utf8
    }

    if (Get-NativeCommand -TestAny 'gh') {
        Write-Debug '[v] completer ⟹ generate: gh' #//⟹
        Invoke-NativeCommand -ea stop 'gh' -ArgumentList @(
            'completion'
            '--shell'
            'powershell'
        ) | Set-Content -Path $CompleterPath.gh
        # rustup completions powershell
        # | Set-Content -Path $CompleterPath.rustup -Encoding utf8
    }
}
# $commandGH = Get-Command -ErrorAction Stop 'gh.exe' -CommandType Application

# }
# & {
# run completers.
function Import-GeneratedCompleter {
    <#
    .synopsis
        generate latest completers for supported commands
    .example
        PS> Build-CustomCompleter
    .link
        Import-CustomCompleter
    .link
        Build-CustomCompleter
    #>
    [cmdletbinding()]
    param()
    # optionally add autocomplete for 'ripgrep',
    $CompleterPath.GetEnumerator() | ForEach-Object {
        $Cmd = $_.Key
        $Src = $_.Value
        Write-Debug "[v] GeneratedCompleter ⟹ loading: $($Cmd)" #//⟹
        if (Test-Path $Src) {
            . $Src
        }
        else {
            Write-Error "[e] GeneratedCompleter ⟹ Not Found: $Cmd [ $Src ]"
        }
        # # try {
        # @(
        #     Hr
        #     $_.Key
        #     Test-Path $_.Value
        #     $_.Value
        # ) | Write-Warning
        # }
        # catch {
        #     Write-Error $_
        # }
    }

}

function Import-CustomCompleter {
    <#
    .synopsis
        internal. imports manually created completers
    .synopsis
        generate latest completers for supported commands
    .example
        PS> Import-CustomCompleter
    .link
        Build-CustomCompleter
    .link
        Import-GeneratedCompleter
    #>

    [cmdletbinding()]
    param()

    $hardCodedList = @(
        'dotnet'
    )
    foreach ($name in $hardCodedList) {
        $Path = Join-Path $PSScriptRoot "${name}.ps1"
        Write-Debug "[v] CustomCompleter ⟹ loading: $Cmd [ $Path ]"
        if (Test-Path $Path) {
            . $Path
        }
        else {
            Write-Error "[e] GeneratedCompleter ⟹ Not Found: $Cmd [ $Src ]"
        }
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


# }
# }
# catch {
#     Write-Error $_
# }
