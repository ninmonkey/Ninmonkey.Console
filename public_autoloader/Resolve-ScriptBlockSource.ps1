#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        '_resolve-ScriptBlockSource'
    )
    $publicToExport.alias += @(
        # 'editFunc' # 'Edit-FunctionSource'
    )
}
function _resolve-ScriptBlockSource {
    <#
    $cmd = Ninmonkey.Console\Resolve-CommandName 'hr'
        $binCode = Get-Command 'code.cmd' -CommandType Application
        # else: use a command from Get-Command
        $codeArgs = @(
            '--goto'
            '"{0}:{1}"' -f @(
                $cmd.ScriptBlock.Ast.Extent.File
                $cmd.ScriptBlock.Ast.Extent.StartLineNumber
                $cmd.Scr
            )
        )
    #>
    param(
        [object]$InputObject
    )
    begin {
        Write-Warning 'wip'
    }

    process {
        if ($false) {
            $extent = $InputObject.ScriptBlock.Ast.Extent
            $Ast.Extent.File
            $cmd.ScriptBlock.Ast.Extent.StartLineNumber
            $cmd.ScriptBlock.Ast.Extent.StartColumnNumber
            # maybe: New-VSCodeFilepath -fromExtent
        }
    }
}
