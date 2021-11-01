# using namespace Management.Automation

$script:publicToExport.function += @(
    'Invoke-NinFormatter'
)
$script:publicToExport.alias += @(
    'Format.ScriptPs1🎨'
)

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
    .outputs

          [string]

    #>
    [alias('FormatScript🎨')]
    [CmdletBinding(PositionalBinding = $false, DefaultParameterSetName = 'FromPipeOrParam')]
    param(
        [Alias('InputObject')]
        [Parameter(
            ParameterSetName = 'FromPipeOrParam',
            Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptDefinition,

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
        Write-Debug $ScriptDefinition

    }
    process {
        # try {
        switch ($PSCmdlet.ParameterSetName) {
            'FromPipeOrParam' {
            }
            'FromHistory' {
                $ScriptDefinition = (Get-History -Count 1 | ForEach-Object CommandLine)
            }
            'FromClipboard' {
                $ScriptDefinition = (Get-Clipboard)
            }

            default {
                Write-Error -ea stop -Category NotImplemented -Message 'Unhandled ParameterSet' -TargetObject $PSCmdlet.ParameterSetName
                # throw "Unhandled ParameterSet: $($PSCmdlet.ParameterSetName)"
            }
        }

        $invokeFormatterSplat = @{
            ScriptDefinition = $ScriptDefinition
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
        # }
        # catch {
        # $PSCmdlet.WriteError( $_ )
        # }
    }
    end {}
}
