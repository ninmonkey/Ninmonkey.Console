if (! $DebugInline) {

    $script:publicToExport.function += @(
        'Get-NinCommandName'
    )
    $script:publicToExport.alias += @(
        '_enumerateMyCommand'
        'MyGcm🐒'
    )
}

function Get-NinCommandName {
    <#
    .synopsis
        like 'Get-Command -Module (mine)'
    .notes
        todo: for Get-NinCommandNameArgumentCompleterAttribute
    .example
        PS> Get-NinCommandName -ListKeys
    .example
        🐒> Get-NinCommandName -Category DevTool💻 -Name *prop*

            DevTool💻-iProp

    .example
        🐒> Get-NinCommandName -Category DevTool💻

            DevTool💻-GetArgumentCompleter
            DevTool💻-GetHiddenArgumentCompleter
            DevTool💻-GetTypeAccellerators
            DevTool💻-iProp
            DevTool💻-Params-FindCommandWithParameterAlias

    .outputs
        [string[]] | [hashtable]
    #>
    [Alias('_enumerateMyCommand', 'MyGcm🐒')]
    [CmdletBinding(PositionalBinding = $false)]
    param(

        # pass filter onto Get-Command -Name
        [Parameter(Position = 0)]
        [string[]]$Name,

        [Parameter(position = 1)]
        [ValidateSet('DevTool💻', 'Conversion📏', 'Style🎨', 'Format🎨', 'ArgCompleter🧙‍♂️', 'NativeApp💻', 'ExamplesRef📚', 'TextProcessing📚', 'Regex🔍', 'Prompt💻', 'Cli_Interactive🖐', 'Experimental🧪', 'UnderPublic🕵️‍♀️', 'My🐒')]
        [string[]]$Category,

        # Docstring
        [Alias('ListCategory')]
        [Parameter()][switch]$ListKeys
    )
    begin {
        if ($ListKeys) {
            $CategoriesMapping
            hr
            'DevTool💻', 'Conversion📏', 'Style🎨', 'Format🎨', 'ArgCompleter🧙‍♂️', 'NativeApp💻', 'ExamplesRef📚', 'TextProcessing📚', 'Regex🔍', 'Prompt💻', 'Cli_Interactive🖐', 'Experimental🧪', 'UnderPublic🕵️‍♀️', 'My🐒'
            | Join-String -sep ' '
            return
        }



        $getCommandSplat = @{
            Module = (_enumerateMyModule)
        }

        "filter: -Name $($Name -join ', ' )" | Write-Debug

        if ( ! [string]::IsNullOrWhiteSpace($Name) ) {
            $getCommandSplat['Name'] = $Name
        }

        $getCommandSplat | Format-HashTable Pair | Write-Debug

        $AllCmds = Get-Command @getCommandSplat | Sort-Object Module, Name, Verb
        $AllFuncInfo = gcm * -m (_enumerateMyModule) | editfunc -PassThru -ea SilentlyContinue
        | % File | % { Get-IndentedFunctionInfo $_ }

        $nativeApp_Cmds = $AllFuncInfo | ? {
            # future: Using AST, detect whether function 'Invoke-NativeCommand' was called
            ($_ | ?str 'nativeapp|nativecommand' ScriptBlock) -or
            ($_ | ?str 'nativeapp|nativecommand' Definition)
        }
        # $AllFuncInfo = gcm * -m (_enumerateMyModule) | editfunc -PassThru | % File | %{ Get-IndentedFunctionInfo $_ }
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


if ( $DebugInline) {
    Get-NinCommandName -ListKeys
    Get-NinCommandName -Category DevTool💻
}
