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
    param(
        # Default includes list view but not
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompletions(
            'MyDefault_HistListView',
            'Using_Plugin'
        )]
        [string]$ImportType
    )



    switch ($ImportType) {
        'Using_Plugin' {
            Write-Debug '
            import: CompletionPredictor
                1] PredictionSource: History+Plugin
        '
            Import-Module CompletionPredictor -Verbose -Scope global
            Set-PSReadLineOption @eaIgnore -PredictionViewStyle ListView -PredictionSource HistoryAndPlugin
            break
        }
        'MyDefault_HistListView' {
            Write-Debug '
            1] predict list view
            2] ctrl+f/d
            3] alt+enter    addLine
            4] ctrl+enter   insertLine

            predictSource: History, style: ListView
            '

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

        default {
            throw "Unhandled Parameter mode: $ImportType"
        }
    }

    Set-PSReadLineKeyHandler -Chord 'alt+enter' -Function AddLine
    # Set-PSReadLineOption -ContinuationPrompt (' ' * 4 | New-Text -fg gray80 -bg gray30 | ForEach-Object tostring )
}

