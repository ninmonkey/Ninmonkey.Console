using namespace System.Collections.Generic

#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Write-VSCodeConsoleMark'

    )
    $publicToExport.alias += @(

    )
    $publicToExport.variable += @(

    )
}

enum VSCodeCustomEscape {

    MarkPromptStart                     # 'OSC 133 ; A ST
    MarkPromptEnd
    MarkPreExecution
    MarkExecutionFinish
    MarkExecutionFinishWithExitCode
}

enum VSCodeTerminalExitReason {
    <#
    https://code.visualstudio.com/updates/v1_71#_extension-authoring

        export enum TerminalExitReason {
            Unknown = 0,
            Shutdown = 1,
            Process = 2,
            User = 3,
            Extension = 4
        }

    #>
    Unknown = 0
    Shutdown = 1
    # Process = 2
    User = 3
    Extension = 4
}


enum UnderlineEscape {
    <#
        <https://code.visualstudio.com/updates/v1_71#_underline-styles-and-colors>

            4:0m    no under
            4:1m    straight
            4:2m    double
            4:3m    curly
            4:4m    dotted
            4:5m    dashed

        > then to set color of underline <https://sw.kovidgoyal.net/kitty/underlines/>
        > This works exactly like the codes 38, 48 that are used to set foreground and background color respectively.

            <ESC>[58...m

        reset:

            <ESC>[59m
    #>
    None
    Straight
    Double
    Curly
    Dotted
    Dashed
}

function Write-VsCodeConsoleMark {
    <#
    .synopsis
        VS Code's new shell marking
    .description
        see: https://code.visualstudio.com/docs/terminal/shell-integration#_setmark-osc-1337-setmark-st
    .NOTES
        - doesn't support as many features as OSC 633.
        - sequences that are supported:

            OSC 133 ; A ST - Mark prompt start
            OSC 133 ; B ST - Mark prompt end
            OSC 133 ; C ST - Mark pre-execution
            OSC 133 ; D [; <exitcode>] ST - Mark execution finished with an optional exit code

        Terminal ExitStatusReason:
            https://code.visualstudio.com/updates/v1_71#_extension-authoring

        see automatic injection, and markings:

            https://github.com/microsoft/vscode/issues/155639
            https://code.visualstudio.com/updates/v1_66#_terminal-shell-integration
            https://code.visualstudio.com/docs/terminal/shell-integration#_automatic-script-injection
            https://code.visualstudio.com/docs/terminal/shell-integration#_setmark-osc-1337-setmark-st

        underline styles:
            <https://code.visualstudio.com/updates/v1_71#_underline-styles-and-colors>
            4:0m    no under
            4:1m    straight
            4:2m    double
            4:3m    curly
            4:4m    dotted
            4:5m    dashed


        > then to set color of underline <https://sw.kovidgoyal.net/kitty/underlines/>
        > This works exactly like the codes 38, 48 that are used to set foreground and background color respectively.

            <ESC>[58...m

        reset:

            <ESC>[59m
    .example
        ...
    .link
        https://code.visualstudio.com/docs/terminal/shell-integration#_setmark-osc-1337-setmark-st
    .link
        https://code.visualstudio.com/docs/terminal/shell-integration#_automatic-script-injection
    #>
    # [Alias('')]
    [CmdletBinding()]
    param(
        # # Command, alias, or function name to search for
        # [Parameter(Position = 0, ValueFromPipeline)]
        # [object[]]$InputObject,
        [ValidateSet()]
        [Parameter(Position = 0, ValueFromPipeline)]
        [string]$EscapeType,

        [hashtable]$Options = @{}

        # # return fullname
        # [switch]$NameOnly,

        # # returns object with source metadadata
        # [switch]$PassThru
    )
    Write-Warning '
    - [ ] read docs on OSC 633
    - [ ] not finished, requires multiple escape codes to be mapped'
    # begin {
    $Config = Join-Hashtable -OtherHash $Options -BaseHash @{
        Template_AnsiEscapeMark = "`e]1337;SetMark`u{07}"
    }
    # [list[object]]$items = @()
    # }
    # process {

    # foreach ($Obj in $InputObject) {
    Write-Debug 'marking'
    $Config.Template_AnsiEscapeMark
    # $Obj
    # }

    # end {}
}
