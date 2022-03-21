using namespace System.Collections.Generic

#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Edit-FunctionSource'
    )
    $publicToExport.alias += @(
        'editFunc' # 'Edit-FunctionSource'
    )
}

function Edit-FunctionSource {
    <#
    .synopsis
        edit the file that contains the source of a function, jump to the line
    .description
        minimal function to find function source. Optionally keep the helper func 'Resolve-CommandName'
    .example
        PS> editfunc 'goto'
        PS> editfunc 'goto' -PassThru
        PS> gcm *-Table* | editFunc -PassThru
    .link
        Ninmonkey.Console\Resolve-CommandName
    .link
        Dev.Nin\New-VSCodeFilepath
    #>
    [Alias('editFunc')]
    [CmdletBinding()]
    param(
        # Command, alias, or function name to search for
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$CommandName,

        # return path to the source
        [switch]$PassThru
    )
    begin {
        [List[object]]$items = [list[object]]::new()
        $binCode = Get-Command 'code.cmd' -CommandType Application -ea stop
    }

    process {
        $items.AddRange( $CommandName )
    }
    end {
        $cmd_list = Ninmonkey.Console\Resolve-CommandName $items
        | Sort-Object -Unique

        $cmd_list | ForEach-Object {
            $cmd = $_
            $codeArgs = @(
                '--goto'
                '"{0}:{1}:{2}"' -f @(
                    $cmd.ScriptBlock.Ast.Extent.File
                    $cmd.ScriptBlock.Ast.Extent.StartLineNumber
                    $cmd.ScriptBlock.Ast.Extent.StartColumnNumber
                )
            )

            $codeArgs | Join-String -sep ' ' -op ($binCode.Name + ' ')
            $codeArgs | Write-Debug
            if ($PassThru) {
                return $cmd.ScriptBlock.Ast.Extent.File | Get-Item
            }
            # todo: simplify using Ninmonkey.Console\Code-Venv
            Start-Process -path $binCode -args $codeArgs -WindowStyle Hidden
        }
    }
}
