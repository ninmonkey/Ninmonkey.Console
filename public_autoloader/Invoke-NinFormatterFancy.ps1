# using namespace Management.Automation

$script:publicToExport.function += @(
    'Invoke-NinFormatterFancy'
)
$script:publicToExport.alias += @(
    'Format.ScriptPs1🎨'
)

# todo: make it a hotkey, also make it indent
function Invoke-NinFormatterFancyFancy {
    <#
    .synopsis
        Automatically format using user's custom rules, from the cli
    .description
       .
    .example
        # formats and saves file
          PS> Invoke-NinFormatterFancy -Path 'c:\foo\bar.ps1' -WriteBack
    .notes
        future: allow piping from:
            [HistoryInfo] | [Microsoft.PowerShell.PSConsoleReadLine+HistoryItem]
    .link
        PSScriptAnalyzer\Invoke-Formatter
    .outputs
          [string]

    #>
    [alias('FormatScript🎨')]
    [CmdletBinding(
        PositionalBinding = $false, DefaultParameterSetName = 'FromPipeOrParam',

        SupportsShouldProcess, ConfirmImpact = 'high'
    )]
    param(

        # pipe script contents
        # Must allow null for piping split text
        [Alias('InputObject')]
        [AllowEmptyString()]
        [AllowNull()]
        [Parameter(
            ParameterSetName = 'FromPipeOrParam',
            Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$ScriptDefinition,

        # modify file in place
        [alias('InputFile')]
        [Parameter(
            Mandatory, ParameterSetName = 'FromFile'
        )]
        [string]$Path,

        # What's the current config?
        [Parameter(ParameterSetName = 'GetConfig')]
        [switch]$GetConfig,

        # replace original file with formatting
        [Parameter(ParameterSetName = 'FromFile')]
        [switch]$WriteBack,

        # Formats Last Command in history
        # [Alias('FromLastCommand', 'PrevCommand', 'FromHistory')]
        [Alias('PrevCommand')]
        [Parameter(
            Mandatory,
            ParameterSetName = 'FromHistory'

        )][switch]$LastCommand,

        # Formats Last Command in history
        [Alias('FromClipboard')]
        [Parameter(
            Mandatory,
            ParameterSetName = 'FromClipboard'
        )][switch]$Clipboard

    )

    begin {
        if ($LastCommand -and $Clipboard) {
            Write-Error 'Choose one of: [ -LastCommand | -Clipboard ]'
        }

        switch ($PSCmdlet.ParameterSetName) {
            'FromPipeOrParam' {
                $scriptContent = ''
            }
            'FromHistory' {
                $scriptContent = (Get-History -Count 1 | ForEach-Object CommandLine)
            }
            'FromClipboard' {
                $scriptContent = (Get-Clipboard)
            }
            'FromFile' {
                $scriptContent = Get-Content ( Get-Item $Path -ea stop)
            }
            'GetConfig' {
                break
            }

            default {
                Write-Error -ea stop -Category NotImplemented -Message 'Unhandled ParameterSet' -TargetObject $PSCmdlet.ParameterSetName
                # throw "Unhandled ParameterSet: $($PSCmdlet.ParameterSetName)"
            }
        }

    }
    process {
        # try {
        switch ($PSCmdlet.ParameterSetName) {
            'FromPipeOrParam' {
                foreach ($line in $ScriptDefinition) {
                    $scriptContent += "`n$line"
                }
            }
            'GetConfig' {
                break
            }
            'FromHistory' {
                break
            }
            'FromClipboard' {
                break
            }
            'FromFile' {
                break
            }

            default {
                Write-Error -ea stop -Category NotImplemented -Message 'Unhandled ParameterSet' -TargetObject $PSCmdlet.ParameterSetName
                # throw "Unhandled ParameterSet: $($PSCmdlet.ParameterSetName)"
            }
        }
    }
    end {
        $invokeFormatterSplat = @{
            ScriptDefinition = $scriptContent -join "`n"
            # formatter requires path, while Invoke-ScriptAnalyzer doe
            Settings         = try {
(Get-Item -ea stop $__ninConfig.Config.PSScriptAnalyzerSettings)?.FullName
            }
            catch {
                Write-Error -m (
                    'Error loading: $__ninConfig.Config.PSScriptAnalyzerSettings = "{0}"' -f @(
                        $__ninConfig.Config.PSScriptAnalyzerSettings
                    )
                )

            }
        }
        'using: $__ninConfig.Config.PSScriptAnalyzerSettings = "{0}"' -f @(
            $__ninConfig.Config.PSScriptAnalyzerSettings
        ) | Write-Debug

        if ($GetConfig) {
            [PSCustomObject]@{
                Settings   = Get-Content $invokeFormatterSplat.Settings
                Path       = $invokeFormatterSplat.Settings
                EnvVarPath = $__ninConfig.Config.PSScriptAnalyzerSettings
            }

            # Wait-Debugger
            return
        }

        $invokeFormatterSplat | Format-dict | Write-Debug

        # try {}

        if ($WriteBack) {
            if ($PSCmdlet.ShouldProcess("$($Path.Name)", 'Replace')) {
                Invoke-Formatter @invokeFormatterSplat | Set-Content $Path
                return
            }
        }
        Invoke-Formatter @invokeFormatterSplat # -Range
    }
}
