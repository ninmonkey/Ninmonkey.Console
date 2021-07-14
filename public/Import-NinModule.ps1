function Import-NinModule {
    <#
    .synopsis
        Import -Force all my modules, one easy command.
    .description
        Maybe an option to dotsource the profile?
            PS> . $PROFILE.NinProfileMainEntryPoint
    .outputs

    #>
    [CmdletBinding(PositionalBinding = $false)]
    param(
        # List of modules, if not the default
        [Parameter(Position = 0)]
        [string[]]$ModuleNames
    )

    begin {}
    process {
        $ModuleNames ??= @(
            _enumerateMyModule
        ) | Sort-Object -Unique

        $ModuleNames | Join-String -sep ', ' -SingleQuote -op 'Loading Modules: '
        | Write-Debug
        Import-Module -Name $ModuleNames -Force -ea SilentlyContinue

    }
    end {}
}
