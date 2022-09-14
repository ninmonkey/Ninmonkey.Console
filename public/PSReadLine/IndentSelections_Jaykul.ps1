<#
About:
    Supports indenting/dedenting multiple lines of selected text

Like VS Code's hotkeys:
    'ctrl+[' / 'ctrl+]'

Original from:
    <https://gist.github.com/Jaykul/761c3b962e1f28998867e120c49c67ae>
#>
& {


    # Hack in a [ReadLine] accelerator
    $xlr8r = [psobject].assembly.gettype('System.Management.Automation.TypeAccelerators')
    if ($xlr8r::AddReplace) {
        $xlr8r::AddReplace('ReadLine', [Microsoft.PowerShell.PSConsoleReadLine])
    }
    else {
        $null = $xlr8r::Remove('ReadLine')
        $xlr8r::Add('ReadLine', [Microsoft.PowerShell.PSConsoleReadLine])
    }

    # Set-PSReadLineKeyHandler -Key 'Alt+(' `
    #     -BriefDescription ParenthesizeSelection `
    #     -LongDescription 'Put parenthesis around the selection or entire line and move the cursor to after the closing parenthesis' `
    #     -ScriptBlock

    # Now some key handlers
    $splatReadline = @{
        BriefDescription = 'Indent/Dedent Selected text'
        Description      = 'Indent/Dedent Selected text like VS Code ctrl+[ / ] ctrl+['
        Chord            = 'Alt+]'
    }

    Set-PSReadLineKeyHandler @splatReadline -ScriptBlock {
        param($key, $arg)
        $start = $null
        $length = $null
        [ReadLine]::GetSelectionState([ref]$start, [ref]$length)

        $command = $null
        $cursor = $null
        [ReadLine]::GetBufferState([ref]$command, [ref]$cursor)

        # if there's no selection, these should be set to the cursor
        if ($start -lt 0) { $start = $cursor; $length = 0 }
        $end = $start + $length
        # Write-Host "`e[s`e[0;0H`e[32mStart:$start End:$end Length:$Length `e[u"

        # pretend that entire lines are selected
        if ($start -gt 0) {
            $start = $command.SubString(0, $start).LastIndexOf("`n") + 1
        }
        $end = $end + $command.SubString($end).IndexOf("`n")
        $length = $end - $start
        # Write-Host "`e[s`e[2;0H`e[34mStart:$start End:$end Length:$Length `e[u"

        $lines = $command.SubString($start, $length)
        $count = ($lines -split "`n").Count
        # Write-Host "`e[s`e[3;0H`e[36m$lines`e[u"
        # Write-Host "`e[s`e[2;0H`e[34mStart:$start End:$end Length:$Length Lines:$Count`e[u"
        [ReadLine]::Replace($start, $length, ($lines -replace '(?m)^', '    '))
        [ReadLine]::SetCursorPosition($start)
        [ReadLine]::SelectLine()

        if ($count -gt 1) {
            while (--$Count) {
                [ReadLine]::SelectForwardChar()
                [ReadLine]::SelectLine()
            }
        }
    }
    $splatReadline = @{
        BriefDescription = 'Indent/Dedent Selected text'
        Description      = 'Indent/Dedent Selected text like VS Code ctrl+[/]'
        Chord            = 'Alt+['
    }

    Set-PSReadLineKeyHandler @splatReadline -ScriptBlock {
        param($key, $arg)
        $start = $null
        $length = $null
        [ReadLine]::GetSelectionState([ref]$start, [ref]$length)

        $command = $null
        $cursor = $null
        [ReadLine]::GetBufferState([ref]$command, [ref]$cursor)

        # if there's no selection, these should be set to the cursor
        if ($start -lt 0) { $start = $cursor; $length = 0 }
        $end = $start + $length
        # Write-Host "`e[s`e[0;0H`e[32mStart:$start End:$end Length:$Length `e[u"

        # pretend that entire lines are selected
        if ($start -gt 0) {
            $start = $command.SubString(0, $start).LastIndexOf("`n") + 1
        }
        $end = $end + $command.SubString($end).IndexOf("`n")
        $length = $end - $start
        # Write-Host "`e[s`e[2;0H`e[34mStart:$start End:$end Length:$Length `e[u"

        $Length = ($length -lt 0) ? 0 : $Length  # exceptions sometimes thrown

        $lines = $command.SubString($start, $length)
        $count = ($lines -split "`n").Count
        # Write-Host "`e[s`e[3;0H`e[36m$lines`e[u"
        # Write-Host "`e[s`e[2;0H`e[34mStart:$start End:$end Length:$Length Lines:$Count`e[u"

        [ReadLine]::Replace($start, $length, ($lines -replace '(?m)^    ', ''))
        [ReadLine]::SetCursorPosition($start)
        [ReadLine]::SelectLine()

        if ($count -gt 1) {
            while (--$Count) {
                [ReadLine]::SelectForwardChar()
                [ReadLine]::SelectLine()
            }
        }
    }
}
