# using namespace Management.Automation

$script:publicToExport.function += @(
    'Invoke-NinFormatter'
)
$script:publicToExport.alias += @(
    'Format.ScriptPs1🎨'
)

# todo: make it a hotkey, also make it indent
function Invoke-NinFormatter {
    <#
    .synopsis
        Automatically format using user's custom rules, from the cli
    .description
       .
    .example
          .
    .notes
        future: allow piping from:
            [HistoryInfo] | [Microsoft.PowerShell.PSConsoleReadLine+HistoryItem]
    .link
        PSScriptAnalyzer\Invoke-Formatter
    .outputs
          [string]

    #>
    [alias('FormatScript🎨')]
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'FromPipeOrParam')]
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
            'FromHistory' {
                break
            }
            'FromClipboard' {
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
        $invokeFormatterSplat | Format-dict | Write-Debug


        # try {}

        Invoke-Formatter @invokeFormatterSplat # -Range
    }
}
