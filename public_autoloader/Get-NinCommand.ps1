#Requires -Version 7.0.0

if (! $__debugInlineNin) {

    $script:publicToExport.function += @(
        'Get-NinCommand'
    )
    $script:publicToExport.alias += @(
        # 'MyGcm🐒'
        'Find-Command🐒'
        # 'MyGet-Command🐒'
    )
}

function Get-NinCommand {
    <#
    .synopsis
        Does far more than wrapping Get-Command. For that check out 'Ninmonkey.Console\Get-NinCommandProxy
    .notes
        maybe this should be Find-NinCommand?
        todo: for Get-NinCommandArgumentCompleterAttribute

    note on naming standards:

        Appending '🐒' because

            autocomplete works exactly the same

        my customized standard functions are aliased like

            gcm -> MyGcm🐒
            ls -> MyLs🐒

        categories

            until categories are added, verbose aliases are defined like

                PS> gcm DevTool💻*

                    DevTool💻-GetArgumentCompleter
                    DevTool💻-GetHiddenArgumentCompleter
                    DevTool💻-GetTypeAccellerators
                    DevTool💻-iProp
                    DevTool💻-Params-FindCommandWithParameterAlias
                    DevTool💻-Params-TestTabExpansionResults

    .example
        PS> Get-NinCommand -ListKeys
    .example
        🐒> Get-NinCommand -Category DevTool💻 -Name *prop*

            DevTool💻-iProp

    .example
        🐒> Get-NinCommand -Category DevTool💻

            DevTool💻-GetArgumentCompleter
            DevTool💻-GetHiddenArgumentCompleter
            DevTool💻-GetTypeAccellerators
            DevTool💻-iProp
            DevTool💻-Params-FindCommandWithParameterAlias
    .link
        Dev.Nin\Get-CommandNameCompleter

    .outputs
        [string[]] | [hashtable]
    #>
    [Alias(
        # 'MyGcm🐒',
        'Find-Command🐒'
    )]
    [CmdletBinding(PositionalBinding = $false)]
    param(

        # pass filter onto Get-Command -Name
        [Parameter(Position = 0)]
        [string[]]$Name,

        [Parameter(position = 1)]
        [ValidateSet(
            'DevTool💻', 'Conversion📏', 'Style🎨', 'Format🎨',
            'ArgCompleter🧙‍♂️', 'NativeApp💻', 'ExamplesRef📚', 'TextProcessing📚',
            'Regex🔍', 'Prompt💻', 'Cli_Interactive🖐', 'Experimental🧪',
            'UnderPublic🕵️‍♀️', 'My🐒', 'Validation🕵',
            'Todo🚧', 'NYI🚧'
        )][string[]]$Category,

        # Docstring
        [Alias('ListCategory')]
        [Parameter()][switch]$ListKeys
    )
    begin {
        if ($ListKeys) {
            $CategoriesMapping
            hr
            @(
                # 'DevTool💻', 'Conversion📏', 'Style🎨', 'Format🎨', 'ArgCompleter🧙‍♂️', 'NativeApp💻', 'ExamplesRef📚', 'TextProcessing📚', 'Regex🔍', 'Prompt💻', 'Cli_Interactive🖐', 'Experimental🧪', 'UnderPublic🕵️‍♀️', 'My🐒', 'Validation🕵'
                # 'Todo🚧', 'NYI🚧',
                'DevTool💻', 'Conversion📏', 'Style🎨', 'Format🎨',
                'ArgCompleter🧙‍♂️', 'NativeApp💻', 'ExamplesRef📚', 'TextProcessing📚',
                'Regex🔍', 'Prompt💻', 'Cli_Interactive🖐', 'Experimental🧪',
                'UnderPublic🕵️‍♀️', 'My🐒', 'Validation🕵',
                'Todo🚧', 'NYI🚧'
            )
            | sort -unique
            | Join-String -sep ', ' -SingleQuote
            return
        }


        $cached_MyModules = _enumerateMyModule # future: todo: only caches current run

        $getCommandSplat = @{
            Module = ($cached_MyModules)
        }

        "filter: -Name $($Name -join ', ' )" | Write-Debug

        if ( ! [string]::IsNullOrWhiteSpace($Name) ) {
            $getCommandSplat['Name'] = $Name
        }

        $getCommandSplat | Format-HashTable Pair | Write-Debug

        $AllCmds = Get-Command @getCommandSplat | Sort-Object Module, Name, Verb
        $AllFuncInfo = Get-Command * -m ($cached_MyModules) | editfunc -PassThru -ea SilentlyContinue
        | ForEach-Object File | ForEach-Object { Get-IndentedFunctionInfo $_ }

        $nativeApp_Cmds = $AllFuncInfo | Where-Object {
            # future: Using AST, detect whether function 'Invoke-NativeCommand' was called
            ($_ | ?str 'nativeapp|nativecommand' ScriptBlock) -or
            ($_ | ?str 'nativeapp|nativecommand' Definition)
        }

        $todoCommands = $AllFuncInfo | Where-Object {
            # future: Using AST, detect whether function 'Invoke-NativeCommand' was called
            ($_ | ?str 'todo' ScriptBlock) -or
            ($_ | ?str 'todo' Definition)
        }
        $NYICommands = $AllFuncInfo | Where-Object {
            # future: Using AST, detect whether function 'Invoke-NativeCommand' was called
            ($_ | ?str '(\bnyi\b)|(\bwip\b)' ScriptBlock) -or
            ($_ | ?str '(\bnyi\b)|(\bwip\b)' Definition)
        }

        # $AllFuncInfo = gcm * -m ($cached_MyModules) | editfunc -PassThru | % File | %{ Get-IndentedFunctionInfo $_ }
        $CategoriesMapping = @{
            'DevTool💻'         = $AllCmds | ?str -Starts 'DevTool💻' Name
            'Conversion📏'      = $AllCmds | ?Str 'ConvertTo|ConvertFrom' Name
            'Style🎨'           = $AllCmds | ?Str '🎨' Name
            'Format🎨'          = $AllCmds | ?Str '🎨|format' Name
            'ArgCompleter🧙‍♂️' = $AllCmds | ?Str 'ArgumentCompleter|Argument|Completer|Completion' Name
            'NativeApp💻'       = $nativeApp_Cmds
            # 'NativeApp💻'       = $AllFuncInfo | ?{   ($_ | ?str 'native.*app' ScriptBlock) -or
            # ($_ | ?str 'native.*app' Definition) } | % Name
            'ExamplesRef📚'     = $AllCmds | ?Str 'Example🔖|Example|Template|Cheatsheet' Name
            'TextProcessing📚'  = @()
            'Experimental🧪'    = $AllCmds | Where-Object { $_.Module -in @('dev.nin') }
            'Regex🔍'           = $AllCmds | ?str 'Regex' Name
            'Todo🚧'           = $todoCommands
            'NYI🚧'           = $NYICommands
            'Prompt💻'          = $AllCmds | ?str 'Prompt' Name
            'UnderPublic🕵️‍♀️' = $AllCmds | ?str -Starts  '_' 'Name'
            'My🐒'              = $AllCmds | ?str '🐒'
            # 'Cli_Interactive🖐' = @()
        }
    }
    process {

        $ValidMatches = $Category | ForEach-Object {
            $curCat = $_

            # is a valid value, and exists
            if ([string]::IsNullOrWhiteSpace($curCat)) {
                return
            }
            if (! $CategoriesMapping.ContainsKey($curCat)) {
                return
            }
            $cmds = $CategoriesMapping[$curCat]
            if ($cmds.length -eq 0) {
                Write-Warning "No commands in category: $curCat"
            }
            $cmds
        } | Sort-Object -Unique

        $ValidMatches | Join-String -sep ', ' -DoubleQuote -op 'ValidMatches for Categories: '
        | Write-Debug



        $AllCmds | Where-Object {
            $curCmd = $_

            if ($CategoriesMapping.Count -eq 0) {
                $true; return
            }
            # todo: refactor: Test-IsAny
            $isMatching = $ValidMatches.Name -contains $curCmd.Name
            # $isMatching = $curCmd -in $ValidMatches
            "'$curCmd' was in $($ValidMatches -join ', ')? $isMatching" | Write-Debug

            if ($isMatching) {
                $true ; return
            }

        } | ForEach-Object { $_.Name } | Sort-Object -Unique

        # if ( ! [string]::IsNullOrWhiteSpace( $Category ) ) {
        #     Write-Error -Category NotImplemented -Message 'Metadata not yet written'
        #     $CategoriesMapping.Keys
        #     $CategoriesMapping.Values
        # }
    }
    end {}
}


if ( $false -and $__debugInlineNin) {
    Get-NinCommand -ListKeys
    Get-NinCommand -Category DevTool💻
}
