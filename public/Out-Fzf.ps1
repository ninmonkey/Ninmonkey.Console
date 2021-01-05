

function Out-Fzf {
    <#
    .synopsis
        uses commandline app 'fzf' similar to 'out-gridview'
    .description
        a simple multi-item selection for the console without the extra features of 'Out-ConsoleGridView'
    .notes
        selected items are returned **in-order** that they are selected in 'fzf'

        'fzf' is documented here:

        - [wiki of fzf examples](https://github.com/junegunn/fzf/wiki/examples)
        - [keybinding and their related ENV vars](https://github.com/junegunn/fzf#key-bindings-for-command-line)
        - [Youtube: Vim universe. fzf - command line fuzzy finder](https://youtu.be/qgG5Jhi_Els)
        - [integrating with 'fd'](https://github.com/junegunn/fzf#respecting-gitignore)
            # Setting fd as the default source for fzf
            export FZF_DEFAULT_COMMAND='fd --type f'
        - [args: preview Window](https://github.com/junegunn/fzf#preview-window)
        - [execute external programs](https://github.com/junegunn/fzf#executing-external-programs)
        - [automatically reloading list](https://github.com/junegunn/fzf#reloading-the-candidate-list)
        - [preview modes](https://github.com/junegunn/fzf#preview-window)
        - [regex-like syntax](https://github.com/junegunn/fzf#search-syntax)
            space delimited like:
                ^music .mp3$ sbtrkt !fire

    env vars:
        main:
            FZF_DEFAULT_COMMAND
            FZF_DEFAULT_OPTS

        hotkey related:
            [hotkey binding docs](https://github.com/junegunn/fzf#key-bindings-for-command-line)
            [hotkey binding wiki](https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings)

            FZF_ALT_C_COMMAND
            FZF_ALT_C_OPTS
            FZF_CTRL_R_OPTS
            FZF_CTRL_T_COMMAND
            FZF_CTRL_T_OPTS

    .example
        PS>
    .notes
        .
    #>
    param (
        # show help
        [Parameter()][switch]$Help,

        # Multi select
        [Parameter()][switch]$MultiSelect = $true,

        # Prompt title
        [Parameter()]
        [String]$PromptText,


        # main piped input
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$InputText,

        # fzf's default is 'reverse'
        # reverse: TextInput on Top
        # reverse-list: TextInput on bottom
        #
        [Parameter()]
        [ValidateSet('default', 'reverse', 'reverse-list')]
        [string]$Layout = 'reverse',

        # Height as a percent. (0, $null, or 100) are full screen
        [Parameter()]
        [AllowNull()]
        [ValidateRange(0, 100)]
        [int]$Height = 30,

        # --min-height=HEIGHT   Minimum height when --height is given in percent
                        #   (default: 10)
        # Height as a percent
        # [Parameter()]
        # [AllowNull()]
        # [ValidateRange(0, 100)]
        # [int]$MinHeight,

        # Exact Match  --exact
        [Parameter()][switch]$ExactMatch,
        [Alias('LoopForever')]
        [Parameter()][switch]$Cycle


        # Optional args as raw text as the final parameter
        # [Parameter()]
        # [string]$FinalArgs

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
        # to: refactor /w Get-NativeCommand
        $binFzf = Get-Command 'fzf' -CommandType Application
        $fzfArgs = @()
        $inputList = [list[string]]::New()

        if ( ! [String]::IsNullOrWhiteSpace(  $PromptText  ) ) {
            $fzfArgs += "--prompt=$PromptText "
        }

        if ($MultiSelect) {
            $fzfArgs += '--multi'
        }
        if($Layout) {
            $fzfArgs += "--layout=$Layout"
        }

        if($Height)  {
            $fzfArgs += "--height=$Height%"
        }

        if($Cycle) {
            $fzfArgs += '--cycle'
        }

        # future ags
        if ($false) {
            if($NotExtended)  { # default is on
                $fzfArgs += "--no-extended"
            }
        @'
            --tac
                'fzf' then switches to Sort Descending
             -n, --nth=N[,..]
            --with-nth=N[,..]
            -d, --delimiter=STR
            --literal
            -n, -nth=<int>
            --no-sort

            --filepath-word
            --jump-labels=CHARS

            --keep-right
'@
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
        $debugMeta.SelectionCount | Label 'Num Selected' | Write-Debug
        $Selection | Join-String -sep ', ' -SingleQuote | Label  'Selection' | Write-Debug

        $fzfArgs | Join-String -sep "`n-" -SingleQuote | Label 'FzfArgs' | Write-Debug
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

<#
NYI args:
    -x, --extended

    -e, --exact
    --algo=TYPE
    -i
    +i
    --literal
    -n, --nth=N[,..]


    --with-nth=N[,..]

    -d, --delimiter=STR
    +s, --no-sort
    --tac
    --phony
    --tiebreak=CRI[,..]



  Interface
    -m, --multi[=MAX]
    --no-mouse
    --bind=KEYBINDS
    --cycle
    --keep-right
    --no-hscroll
    --hscroll-off=COL

    --filepath-word
    --jump-labels=CHARS

  Layout
    --height=HEIGHT[%]

    --min-height=HEIGHT

    --layout=LAYOUT
    --border[=STYLE]

    --margin=MARGIN
    --info=STYLE
    --prompt=STR
    --pointer=STR
    --marker=STR
    --header=STR
    --header-lines=N

  Display
    --ansi
    --tabstop=SPACES
    --color=COLSPEC
    --no-bold

  History
    --history=FILE
    --history-size=N

  Preview
    --preview=COMMAND
    --preview-window=OPT


  Scripting
    -q, --query=STR
    -1, --select-1
    -0, --exit-0
    -f, --filter=STR
    --print-query
    --expect=KEYS
    --read0
    --print0
    --sync
    --version

  Environment variables
    FZF_DEFAULT_COMMAND
    FZF_DEFAULT_OPTS

#>