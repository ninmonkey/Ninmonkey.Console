using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# This example will replace any aliases on the command line with the resolved commands.
$splatKeys = @{
    Key              = 'Alt+%'
    BriefDescription = 'Expands aliases'
    LongDescription  = 'Replace all aliases with the full command'
}

Set-PSReadLineKeyHandler @splatKeys -ScriptBlock {
    param($key, $arg)

    $ast = $null
    $tokens = $null
    $errors = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$ast, [ref]$tokens, [ref]$errors, [ref]$cursor)

    $startAdjustment = 0
    foreach ($token in $tokens) {
        if ($token.TokenFlags -band [TokenFlags]::CommandName) {
            $alias = $ExecutionContext.InvokeCommand.GetCommand($token.Extent.Text, 'Alias')
            # edit: why did the original not compare with null on LHS ? Accident? error?
            if ($alias -ne $null) {
                $resolvedCommand = $alias.ResolvedCommandName
                if ($resolvedCommand -ne $null) {
                    $extent = $token.Extent
                    $length = $extent.EndOffset - $extent.StartOffset
                    [Microsoft.PowerShell.PSConsoleReadLine]::Replace(
                        $extent.StartOffset + $startAdjustment,
                        $length,
                        $resolvedCommand)

                    # Our copy of the tokens won't have been updated, so we need to
                    # adjust by the difference in length
                    $startAdjustment += ($resolvedCommand.Length - $length)
                }
            }
        }
    }
    if ($ENV:NinEnableToastDebug) {
        New-BurntToastNotification -Text ($Tokens | Join-String -sep ' ' -SingleQuote )
    }
}
