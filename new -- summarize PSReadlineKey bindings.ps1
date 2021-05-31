

function _summarizeKeybind {
    <#
    .synopsis
        make testing keybindings readable for the cli
    .example
        PS> _summarizeKeybind '^f\d$'

            F1 = ShowCommandHelp; F2 = SwitchPredictionView; F3 = CharacterSearch; F8 = HistorySearchBackward

        PS> _summarizeKeybind 'enter'

            Alt+Enter = InsertLineBelow; Ctrl+Enter = InsertLineAbove; Enter = AcceptLine; Shift+Ctrl+Enter = InsertLineBelow; Shift+Enter = AddLine
    #>
    param(
        # Regex
        [Parameter(Position = 0)]
        [string]$PatternKeybind
    )

    begin {
        $splat_JoinKeys = @{
            Separator    = '; '
            OutputSuffix = "`n"
            Property     = { $_.Key, $_.Function -join ' = ' }
        }
    }

    process {
        Label 'Pattern' $PatternKeybind | Write-Information
        Get-PSReadLineKeyHandler -Bound
        | Where-Object { $_.Key -match $PatternKeybind }
        | Sort-Object Key
        | Join-String @splat_JoinKeys
    }
}

_summarizeKeybind '^f\d$' -InformationAction Continue
_summarizeKeybind 'enter' -InformationAction Continue

# Get-PSReadLineKeyHandler -Bound | Where-Object { $_.Key -match 'f[12]' }
# | Sort-Object Key
# | Join-String -sep '; ' { $_.Key, $_.Function -join ' = ' } -os ''