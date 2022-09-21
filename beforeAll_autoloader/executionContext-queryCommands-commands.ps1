#Requires -Version 7

Write-Warning "still in debug mode $PSCommandPath"
<#



#>
function _getNativeCommand {
    param(
        [Alias('LiteralName')]
        [string]$Name,

        [Alias('WildCard')]
        [switch]$UsingWildcard

    )
    throw 'get below, or other ref'
}
# $sess.InvokeCommand.GetCommand('git', [CommandTypes]::Application )

# if ( $publicToExport ) {
#     $publicToExport.function += @(
#         'Test-PathsAreEqual'
#         'Ensure-CurWorkingDirectory'
#     )
#     $publicToExport.alias += @(
#         '_ensureCwd' # 'Ensure-CurWorkingDirectory'
#         'Ensure->Cwd' # 'Ensure-CurWorkingDirectory'
#     )
# }

return

$ExecutionContext.InvokeCommand.GetCommandName('gi*', $false, $true)
# 63    0.051 $ExecutionContext.InvokeCommand.GetCommandName('gi*', $true, $true)
# 62    0.028 $ExecutionContext.InvokeCommand.GetCommandName('gi', $true, $true)
# 61    0.022 $ExecutionContext.InvokeCommand.GetCommandName('gi', $false, $true)
# 60    0.021 $ExecutionContext.InvokeCommand.GetCommandName('git', $false, $true)
# 59    0.026 $ExecutionContext.InvokeCommand.GetCommandName('git', $false)
# 58    0.026 $ExecutionContext.InvokeCommand.GetCommandName('git', $false, $true)
# 57    0.027 $ExecutionContext.InvokeCommand.GetCommandName('git', $true, $true)
# 56    0.023 $ExecutionContext.InvokeCommand.GetCommandName('git', $true)
# 55    0.027 $ExecutionContext.InvokeCommand.GetCommandName('git')
# 54    0.018 $ExecutionContext.InvokeCommand.GetCommandName
# 53    0.481 $sess.InvokeCommand.GetCommand('code.exe', [CommandTypes]::Application )
# 52    0.022 $sess.InvokeCommand.GetCommand('code.cmd', [CommandTypes]::Application )
# 51    0.034 $sess.InvokeCommand.GetCommand('code', [CommandTypes]::Application )
# 50    0.032 & $Null

# 64    0.006 $ExecutionContext.InvokeCommand.GetCommandName('gi*', $false, $true)
# 63    0.051 $ExecutionContext.InvokeCommand.GetCommandName('gi*', $true, $true)
# 62    0.028 $ExecutionContext.InvokeCommand.GetCommandName('gi', $true, $true)