if ( $publicToExport ) {
    $publicToExport.function += @(
        'nin.ImportPSReadLine'
    )
    $publicToExport.alias += @(
        # 'nin.ImportPSReadLine'
    )
}


function nin.ImportPSReadLine {
    <#
    AddLine
        moves to next line, bringing any remaining text with it
    AddLineBelow
        Adds and moves to next line, leaving text where it was.

     now VS Code supports it, making it the default
    #>
    [CmdletBinding()]
    param(
        # Default includes list view but not
        [Parameter(Mandatory, Position = 0)]
        # [ArgumentCompletions(
        [ValidateSet(
            'MyDefault_HistListView',
            'Using_Plugin', 'Default'
        )]
        [string]$ImportTemplateName
    )
    if ( [string]::IsNullOrWhiteSpace($ImportTemplateName)) {
        $ImportTemplateName = 'Default'
    }
    switch ($ImportTemplateName) {
        'Using_Plugin' {
            '
ImportTemplateName: Using_Plugin
About:
    PredictionSource: History+Plugin

Expression:

    Import-Module CompletionPredictor
    Set-PSReadLineOption @eaIgnore -PredictionViewStyle ListView -PredictionSource HistoryAndPlugin
        '
            | Write-Verbose
            # | Write-Information -infa 'continue'

            Import-Module CompletionPredictor -Verbose -Scope global
            Set-PSReadLineOption @eaIgnore -PredictionViewStyle ListView -PredictionSource HistoryAndPlugin
            break
        }
        'MyDefault_HistListView' {
            @'
ImportTemplateName: MyDefault_HistListView
Expression:

    Set-PSReadLineOption
        -PredictionSource History
        -PredictionViewStyle ListView
        -ContinuationPrompt ((' ' * 4) -join '')

    Keybind:
        'Ctrl+f'    -Fn ForwardWord
        'Ctrl+d'    -Fn BackwardWord
        'alt+enter' -Fn AddLine
        'ctrl+enter'-Fn InsertLineAbove

Summary:
    1] predict list view
    2] ctrl+f/d
    3] alt+enter    addLine
    4] ctrl+enter   insertLine

predictSource: History, style: ListView
'@
            | Write-Verbose

            Set-PSReadLineOption @eaIgnore -PredictionSource History
            Set-PSReadLineOption @eaIgnore -PredictionViewStyle ListView

            Set-PSReadLineOption -ContinuationPrompt ((' ' * 4) -join '')

            Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -Function ForwardWord
            Set-PSReadLineKeyHandler -Chord 'Ctrl+d' -Function BackwardWord
            # Get-PSReadLineKeyHandler -Bound -Unbound | Where-Object key -Match 'Enter|^l$' | Write-Debug
            Set-PSReadLineKeyHandler -Chord 'alt+enter' -Function AddLine
            Set-PSReadLineKeyHandler -Chord 'ctrl+enter' -Function InsertLineAbove
            'no-op' | Write-Debug
            break
        }

        'Default' {
            @'
ImportTemplateName: Default
Expression:

    Keybind:
        'alt+enter' -Fn 'AddLine'
'@
            Set-PSReadLineKeyHandler -Chord 'alt+enter' -Function AddLine
            # Set-PSReadLineOption -ContinuationPrompt (' ' * 4 | New-Text -fg gray80 -bg gray30 | ForEach-Object tostring )
            break
        }
        default {
            throw "Unhandled Parameter mode: $ImportType"
        }
    }

}

