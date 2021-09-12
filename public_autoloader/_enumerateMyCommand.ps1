if (! $DebugInline) {

    $script:publicToExport.function += @('Get-NinCommandName')
    $script:publicToExport.alias += @('_enumerateMyCommand')
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
        PS> Get-NinCommandName -Category DevTool💻
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


        $AllCmds = Get-Command -Module (_enumerateMyModule) | Sort-Object Module, Name, Verb
        $CategoriesMapping = @{
            'DevTool💻'         = $AllCmds | ?str -Starts 'DevTool💻' Name
            'Conversion📏'      = @()
            'Style🎨'           = $AllCmds | ?Str '🎨|color' Name
            'Format🎨'          = $AllCmds | ?Str '🎨|format' Name
            'ArgCompleter🧙‍♂️' = @()
            'NativeApp💻'       = @()
            'ExamplesRef📚'     = @()
            'TextProcessing📚'  = @()
            'Regex🔍'           = @()
            'Prompt💻'          = @()
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
            if (! $CategoriesMapping.ContainsKey($curCat )) {
                $cmds = $CategoriesMapping[$curCat]
            }
            $cmd ??= @()
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
            $isMatching = $curCmd.Name -in $ValidMatches.Name
            "'$curCmd' was in $($ValidMatches -join ', ')? $isMatching" | Write-Debug

            if ($isMatching) {
                $true ; return
            }

        } | ForEach-Object { $_.Name }

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
