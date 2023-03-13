#Requires -Version 7



if ( $publicToExport ) {
    $publicToExport.function += @(
        'Edit-FunctionSource'
    )
    $publicToExport.alias += @(
        'editFunc' # 'Edit-FunctionSource'
    )
    $publicToExport.variable += @(
        'ninLastPath' # from: 'Ninmonkey.Console\Edit-FunctionSource'
    )
}

function Format-NativeCommandArguments {
    <#
    .SYNOPSIS
        render and emphasize command line args for a command
    .EXAMPLE
        $clargs = @('log', '-n', '1')
        $clargs | Format-NativeCommandArguments -CommandName 'git'
        Format-NativeCommandArguments -CommandName 'git' -Args $clargs
        # output:
             => invoke: sam log -n 1
    .EXAMPLE
        # works with positional set
        Format-NativeCommandArguments 'git' $clargs
        $clargs | Format-NativeCommandArguments 'git'
    .EXAMPLE
        Format-NativeCommandArguments 'code' '--goto', 'someFile.log:242'
    .EXAMPLE
        $clargs = @('--goto', (gi '..\README.md'))
        $clargs | Format-NativeCommandArguments 'code'
    .EXAMPLE
        get-date | sc 'temp:\now.txt'
        sleep 0.01
        get-date | sc 'temp:\now with spaces.txt'

        $vscodeDiff = @(
            '--reuse-window'
            '--diff'
            gi 'temp:\now.txt'
            gi 'temp:\now with spaces.txt'
        )

        Format-NativeCommandArguments 'code' $vscodeDiff
    #>
    [Alias('aw.renderClargs')]
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        # binary name
        [Parameter(Mandatory, Position = 0)]
        [string]$CommandName,

        # render [object[]] arguments
        [Alias('Args')]
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [object[]]$InputArgs = @()
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
        $ColorOrange = @(
            $PSStyle.Foreground.fromRgb('#c8834b')
            $PSStyle.Background.fromRgb('#362b1f')
        ) -join ''
    }
    process {
        $items.AddRange($inputArgs)
    }
    end {
        $Items
        | Join-String -op "  => invoke: ${CommandName} " -sep ' '
        | Join-String -op $ColorOrange -os $PSStyle.Reset -sep ' '
        # $Args | Join-String -sep ' ' -op "execute => ${CommandName}: "
    }
}

function Edit-FunctionSource {
    <#
    .synopsis
        edit the file that contains the source of a function, jump to the line
    .description
        minimal function to find function source. Optionally keep the helper func 'Resolve-CommandName'
    .example
        # opens in an editor
        PS> editfunc 'prompt'

        # return object / [ScriptExtent]
        PS> editfunc 'goto' -PassThru

        # return filepath only
        PS> editfunc 'goto' -NameOnly

    .example
        PS> gcm *-Table* | editFunc -PassThru
        editfunc nls -PassThru
        editfunc nls -NameOnly
        editfunc len -infa continue
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

        # return fullname
        [switch]$NameOnly,

        # returns object with source metadadata
        [switch]$PassThru
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
        $binCode = Get-Command 'code.cmd' -CommandType Application -ea stop
    }

    process {
        $items.AddRange( $CommandName )
    }
    end {
        $cmd_list = Ninmonkey.Console\Resolve-CommandName $items
        | Sort-Object -Unique
        # [console]::WriteLine
        # test-path -

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

            # Write-Debug 'wrote $global:ninLastPath'
            $global:ninLastPath = $cmd.ScriptBlock.Ast.Extent.File | Get-Item

            $codeArgs | Join-String -sep ' ' -op ($binCode.Name + ' ') | Write-Debug
            if ($NameOnly) {
                return $cmd.ScriptBlock.Ast.Extent.File | Get-Item | ForEach-Object FullName
            }

            if ($PassThru) {
                return $cmd.ScriptBlock.Ast.Extent
            }
            # todo: simplify using Ninmonkey.Console\Code-Venv

            $cmd.ScriptBlock.Ast.Extent.File
            | Join-String -op 'loading:... <' -os '>' { $_ }
            | Write-Information
            Start-Process -path $binCode -WindowStyle 'Hidden' -args $codeArgs
        }
    }
}
