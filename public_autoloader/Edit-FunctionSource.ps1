#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Edit-FunctionSource' # 'EditFunc'
        'Find-FunctionSource' # 'FindFunc
    )
    $publicToExport.alias += @(
        'EditFunc' # 'Ninmonkey.Console\Edit-FunctionSource'
        'FindFunc' # 'Ninmonkey.Console\Find-FunctionSource'
    )
    $publicToExport.variable += @(
        'ninLastPath' # from: 'Ninmonkey.Console\Edit-FunctionSource'
    )
}
<#
to fix:
    FindFunc '*xl*' -AsText
        errors

and then do not pass start-process  using wildcard
    EditFunc '*xl*' -AsObject | % file
#>
function Find-FunctionSource {
    <#
    .synopsis
        Shorthand for finding filepaths of functions to dedit
    .description
        minimal function to find function source. Optionally keep the helper func 'Resolve-CommandName'
    .link
        Ninmonkey.Console\Edit-FunctionSource
    .example
        PS> FindFunc 'nin.*' | Sort -Unique

        H:\data\2023\dotfiles.2023\pwsh\profile.ps1
        H:\data\2023\dotfiles.2023\pwsh\src\__init__.ps1
        H:\data\2023\dotfiles.2023\pwsh\src\autoloadNow_butRefactor.ps1
    .example
        # pipe wildcards from gcm
        PS> gcm .fmt.* | EditFunc -PassThru | % File

    .example
        PS> gcm *-Table* | FindFunc

            editfunc nls -PassThru
            editfunc nls -NameOnly
            editfunc len -infa continue
    .link
        Ninmonkey.Console\Resolve-CommandName
    .link
        Ninmonkey.Console\Find-FunctionSource
    .link
        Ninmonkey.Console\Edit-FunctionSource
    .link
        Dev.Nin\New-VSCodeFilepath
    #>
    [Alias('FindFunc')]
    [CmdletBinding()]
    param(
        # Command, alias, or function name to search for
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$CommandName,


        # return fullname
        [Alias('AsText')]
        [switch]$NameOnly,

        # returns object with source metadadata
        [Alias('AsObject')]
        [switch]$PassThru
    )
    #>
    begin {
        [Collections.Generic.List[Object]]$Items = @()
    }

    process {
        $items.AddRange(@( $CommandName ) )
    }
    end {
        $errList = $null
        # $Items | Edit-FunctionSource -
        # Edit-FunctionSource -CommandName $Items -AsObject
        Edit-FunctionSource -CommandName $Items -AsText -ev 'errList'
        | Sort-Object -Unique
        # | Get-Item -ErrorVariable 'errList' -ea 'silentlycontinue'
        if ($errList.count -gt 0) {
            Write-Warning 'errors occurred, next: refactor EditFunc to use Debug.ExecutionContext instead of ResolveCommandName'
        }
        # | ForEach-Object File
        # | Get-Item -ea 'break'
    }
}

function Edit-FunctionSource {
    <#
    .synopsis
        edit the file that contains the source of a function, jump to the line
    .description
        minimal function to find function source. Optionally keep the helper func 'Resolve-CommandName'
    .example
        # pipe wildcards from gcm
        PS> gcm .fmt.* | EditFunc -PassThru | % File

            H:\data\2023\dotfiles.2023\pwsh\src\autoloadNow_butRefactor.ps1
            H:\data\2023\dotfiles.2023\pwsh\src\autoloadNow_ArgumentCompleter-butRefactor.ps1
            H:\data\2023\dotfiles.2023\pwsh\src\autoloadNow_ArgumentCompleter-butRefactor.ps1
            H:\data\2023\dotfiles.2023\pwsh\src\autoloadNow_butRefactor.ps1
            H:\data\2023\dotfiles.2023\pwsh\src\__init__.ps1
            H:\data\2023\dotfiles.2023\pwsh\profile.ps1
    .example
        # opens in an editor
        PS> editfunc 'prompt'

        # return object / [ScriptExtent]
        PS> editfunc 'goto' -PassThru

        # return filepath only
        PS> editfunc 'goto' -NameOnly

    .example
        PS> gcm *-Table* | EditFunc -PassThru
        editfunc nls -PassThru
        editfunc nls -NameOnly
        editfunc len -infa continue
    .link
        Ninmonkey.Console\Resolve-CommandName
    .link
        Ninmonkey.Console\Find-FunctionSource
    .link
        Ninmonkey.Console\Edit-FunctionSource
    .link
        Dev.Nin\New-VSCodeFilepath
    #>
    [Alias('EditFunc')]
    [OutputType(
        'System.Management.Automation.Language.InternalScriptExtent',
        'System.Object') ]
    [CmdletBinding()]
    param(
        # Command, alias, or function name to search for
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$CommandName,


        # return fullname
        [Alias('AsText')]
        [switch]$NameOnly,

        # returns object with source metadadata
        [Alias('AsObject')]
        [switch]$PassThru
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
        $binCode = Get-Command 'code' -CommandType Application -ea 'stop' | Select-Object -First 1
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
            $global:ninLastPath = $cmd.ScriptBlock.Ast.Extent.File | Get-Item -ea 'ignore'

            $codeArgs | Join-String -sep ' ' -op ($binCode.Name + ' ') | Write-Debug
            if ($NameOnly) {
                return $cmd.ScriptBlock.Ast.Extent.File | Get-Item | ForEach-Object FullName
            }

            if ($PassThru) {
                return $cmd.ScriptBlock.Ast.Extent
            }
            # todo: simplify using Ninmonkey.Console\Code-Venv

            $cmd.ScriptBlock.Ast.Extent.File
            # | Get-Item #-ea 'silentlyContinue'
            | Get-Item -ea 'silentlyContinue'
            | Join-String -op 'loading:... <' -os '>' { $_ }
            | Write-Information
            Start-Process -path $binCode -WindowStyle 'Hidden' -args $codeArgs
        }
    }
}
