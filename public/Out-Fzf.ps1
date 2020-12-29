function Out-Fzf {
    <#
    .synopsis
        uses commandline app 'fzf' similar to 'out-gridview'
    .description
        a simple multi-item selection for the console without the extra features of 'Out-ConsoleGridView'
    .notes
        selected items are returned **in-order** that they are selected in 'fzf'

        'fzf' is documented here:

        - [keybinding and their related ENV vars](https://github.com/junegunn/fzf#key-bindings-for-command-line)
        - [Youtube: Vim universe. fzf - command line fuzzy finder](https://youtu.be/qgG5Jhi_Els)

        - [args: preview Window](https://github.com/junegunn/fzf#preview-window)

    .example
        PS>
    .notes
        .
    #>
    param (
        # show help
        [Parameter()][switch]$Help,

        # Multi select
        [Parameter()][switch]$MultiSelect,

        # Prompt title
        [Parameter()]
        [String]$PromptText,


        # main piped input
        [Parameter(
            Mandatory, ValueFromPipeline)]
        [string[]]$InputText

        # [1] Future: param -Property
        # [2] future: support PSObjects with property '.Name' or ToString


        # future: Maximum selection: --multi[=max]
        # [Parameter()][int]$MaxMultiSelect
    )

    begin {
        $debugMeta = @{}

        if ($Help) {
            '<https://github.com/junegunn/fzf#tips> and ''fzf --help'''
            break
        }
        $binFzf = Get-Command 'fzf' -CommandType Application
        $fzfArgs = @()
        $inputList = [list[string]]::New()

        if ( ! [String]::IsNullOrWhiteSpace(  $PromptText  ) ) {
            $fzfArgs += ("--prompt={0}" -f $PromptText)
        }

        if ($MultiSelect) {
            $fzfArgs += '--multi'
        }

        $debugMeta.FzfArgs = $fzfArgs
    }
    process {
        foreach ($Line in $InputText) {
            $inputList.add( $Line )
        }
    }

    end {
        $Selection = $inputList | & $binFzf @fzfArgs
        $Selection

        # style 1]
        # $debugMeta.InputListCount = $inputList.Count
        # $debugMeta.SelectionCount = $Selection.Count
        # $debugMeta.Selection = $Selection | Join-String -sep ', ' -SingleQuote | Label 'Selection'

        # style 2]
        # style wise, this looks cleaner, but throws on duplicate key names
        $debugMeta += @{
            InputListCount = $inputList.Count
            SelectionCount = $Selection.Count
            Selection      = $Selection | Join-String -sep ', ' -SingleQuote | Label  'Selection'

        }
        $debugMeta | Format-HashTable -Title '@debugMeta' | Write-Debug
    }
}

if ($false) {
    Goto $nin_paths.GithubDownloads
    <# examples
        Out-Fzf -Debug -Help
        Out-Fzf -Debug -PromptText 'cat' -Help
        # $x = Out-Fzf
        #>

    Get-ChildItem | Select-Object -First 3
    | Out-Fzf -Debug

    # Get-ChildItem -Name | Out-Fzf -MultiSelect -Debug
}
