if (! $DebugInline) {

    $script:publicToExport.function += @(
        'Get-NinCommandName'
    )
    $script:publicToExport.alias += @(
        '_enumerateMyCommand'
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
    [Alias('_enumerateMyCommand')]
    [CmdletBinding(PositionalBinding = $false)]
    param(

        # pass filter onto Get-Command -Name
        [Parameter(Position = 0)]
        [string[]]$Name,

        [Parameter(position = 1)]
        [ValidateSet('DevTool💻', 'Conversion📏', 'Style🎨', 'Format🎨', 'ArgCompleter🧙‍♂️', 'NativeApp💻', 'ExamplesRef📚', 'TextProcessing📚', 'Regex🔍', 'Prompt💻', 'Cli_Interactive🖐')]
        [string[]]$Category,

        # Docstring
        [Alias('ListCategory')]
        [Parameter()][switch]$ListKeys
    )
    begin {
        $isCategory


        $getCommandSplat = @{
            Module = (_enumerateMyModule)
        }

        "filter: -Name $($Name -join ', ' )" | Write-Debug

        if ( ! [string]::IsNullOrWhiteSpace($Name) ) {
            $getCommandSplat['Name'] = $Name
        }

        $getCommandSplat | Format-HashTable Pair | Write-Debug

        $AllCmds = Get-Command @getCommandSplat | Sort-Object Module, Name, Verb
        $CategoriesMapping = @{
            'DevTool💻'         = $AllCmds | ?str -Starts 'DevTool💻' Name
            'Conversion📏'      = @()
            'Style🎨'           = $AllCmds | ?Str '🎨' Name
            'Format🎨'          = $AllCmds | ?Str '🎨|format' Name
            'ArgCompleter🧙‍♂️' = @()
            'NativeApp💻'       = @()
            'ExamplesRef📚'     = @()
            'TextProcessing📚'  = @()
            'Regex🔍'           = $AllCmds | ?str 'Regex'
            'Prompt💻'          = $AllCmds | ?str 'Prompt'
            'Cli_Interactive🖐' = @()
        }
    }
    process {
        if ($ListKeys) {
            $CategoriesMapping
            return
        }

        $ValidMatches = $Category | ForEach-Object {
            $curCat = $_
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
