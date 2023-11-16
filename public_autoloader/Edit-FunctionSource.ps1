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
        PS> gcm editfunc | editfunc -AsText
        PS> gcm editfunc | editfunc -AsFileInfo
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
    .NOTES
        maybe because of enumeration, unique isn't getting distinct list with wildcards

        - [ ] todo: fix this:

            editfunc dotils* -AsFileInfo | sort-object -Unique | OutNull

        todo:
            - [ ]  I should modernize this, both the code and the cmdlet Interface

        better passthru type
            - [ ] enable it so that piping by propertynames works for Get-Item FileInfo Paths

        - [ ] enable piping by propertytypes or property names automatically for  types
            - [ ] Get-Item recieves [FileInfo]
            - [ ] Get-Command uses [sma.CommandTypes]
                    gcm prompt | .IsType FullName

    - [ ] these should be supported

        editfunc Func | Get-Help
        editfunc Func | Get-Item
        editfunc Func | Goto        # vscode edit

    - [ ] for fun
        - [ ] PSMetrics
            gives metrics on that specific scriptExtent, not the entire file
        - [ ] editfunc Func -AskWhichWhenMultiple
            so if there's two modules, you only need to enter it when 2+ matches are found
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
        'System.IO.FileInfo',
        'System.Object') ]
    [CmdletBinding()]
    param(
        # Command, alias, or function name to search for
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$CommandName,


        # return fullname. Returns: [String]
        [Alias(
            'AsText', 'AsFullName')]
        [switch]$FullName,


        # Return AsText through Get-Item. Returns: [IO.FileInfo]
        [Alias('AsFile')]
        [switch]$AsFileInfo,

        # returns object with source metadadata. Returns [smal.InternalScriptExtent]
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
            | Sort-Object -Unique Source, Name
        # [console]::WriteLine
        # test-path
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


            #always blank
            # $maybePath? =
            #     $cmd.ScriptBlock.Ast.Extent.File ?? $null

            # if( [string]::IsNullOrWhiteSpace( $maybePath? ) ) {
            #     write-warning 'EditFunc::Ast.Extent.File is Blank'
            #     return
            # }

            # Write-Debug 'wrote $global:ninLastPath'
            $global:ninLastPath =
                $cmd.ScriptBlock.Ast.
                    Extent.File | Get-Item -ea 'ignore'

            $codeArgs | Join-String -sep ' ' -op ($binCode.Name + ' ') | Write-Debug
            if( $PassThru )  {
                $cmd.ScriptBlock.Ast.Extent.GetType()
                    | Join-String -op 'EditFunc::Returning Type: ' | Write-Verbose

                return $cmd.ScriptBlock.Ast.
                    Extent
                    | Sort-Object -Unique File

            }
            if ($FullName) {
                'EditFunc::Returning Type: [String]' | Write-Verbose
                return $cmd.ScriptBlock.Ast.
                    Extent.File | Get-Item
                    | ForEach-Object FullName
                    | Sort-Object -Unique
            }
            if($AsFileInfo) {
                'EditFunc::Returning Type: [String]' | Write-Verbose
                return $cmd.ScriptBlock.Ast.
                    Extent.File | Get-Item
                    | Sort-Object -Unique FullName
            }

            # todo: simplify using Ninmonkey.Console\Code-Venv

            'EditFunc::Returning Nothing, Invoking Code..'
                | Write-Verbose

            $cmd.ScriptBlock.Ast.Extent.File
                # | Get-Item #-ea 'silentlyContinue'
                | Get-Item -ea 'silentlyContinue'
                | Join-String -op 'loading:... <' -os '>' { $_ }
                | Write-Information #-infa Continue

            Start-Process -path $binCode -WindowStyle 'Hidden' -args $codeArgs
        }
    }
}
