function Import-NinPSReadLineKeyHandler {
    <#
    .synopsis
        opt-in to keybindings
    #>
    [Alias('Import-NinKeys')]
    [CmdletBinding()]
    param (
        # docstring
        # [Parameter()
        # [TypeName]$ParameterName
    )
    '::Import-NinPSReadLineKeyHandler => enter' | Write-Host -fg 'orange'

    foreach ($extension in $psreadline_extensions) {
        $src = Join-Path $PSScriptRoot "PSReadLine\${extension}.ps1"
        if (Test-Path $src) {
            . $src
        }
        else {
            Write-Error "Import failed: '$src'"
        }
    }

}
