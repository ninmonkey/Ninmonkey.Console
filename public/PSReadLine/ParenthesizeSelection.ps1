using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# Sometimes you want to get a property of invoke a member on what you've entered so far
# but you need parens to do that.  This binding will help by putting parens around the current selection,
# or if nothing is selected, the whole line.
Set-PSReadLineKeyHandler -Key 'Alt+(' `
    -BriefDescription ParenthesizeSelection `
    -LongDescription 'Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis' `
    -ScriptBlock {
    param($key, $arg)

    $selectionStart = $null
    $selectionLength = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState(
        [ref]$selectionStart, [ref]$selectionLength
    )

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState(
        [ref]$line, [ref]$cursor
    )

    if ($selectionStart -ne -1) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
            $selectionStart, $selectionLength,
            '(' + $line.SubString($selectionStart, $selectionLength) + ')'
        )
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition(
            $selectionStart + $selectionLength + 2
        )
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
            0, $line.Length, '(' + $line + ')'
        )
        [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
    }
}
