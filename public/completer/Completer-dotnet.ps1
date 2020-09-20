using namespace System.Management.Automation
using namespace System.Management.Automation.Language

<#
.description
    add autocompletion to the command `dotnet`
.notes
see:
    - [Docs: Register-AutoCompleter](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/register-argumentcompleter?view=powershell-7)
    - [docs: Automation.CompletionResult ](https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.completionresult?view=powershellsdk-7.0.0)

#>
# function Add-NativeAutoCompleterDotnet {
'todo: refactor inline constants'

# $temp_old_Debug = $DebugPreference
function New-CompletionResult {
    <#
    .synopsis
        Create a [System.Management.Automation.CompletionResult]
    .example
        PS> New-CompletionResult '--info' 'info' ParameterName 'List installed .net runtimes'

        CompletionText : --info
        ListItemText   : info
        ResultType     : ParameterName
        ToolTip        : List installed .net runtime
    #>
    param(
        [Parameter(
            Mandatory, Position = 0,
            HelpMessage = "Completion Result returned")]
        [string]$CompletionText,

        [Parameter(
            Mandatory, Position = 1,
            HelpMessage = 'Text displayed in the popup, usually equal to -CompletionText without a "--" prefix. ')]
        [string]$ListItemText,

        [Parameter(
            Mandatory, Position = 2,
            HelpMessage = "enum: [System.Management.Automation.CompletionResultType]")]
        [CompletionResultType]$ResultType,

        [Parameter(
            Mandatory, Position = 3, HelpMessage = 'Verbose description shown when a single command is selected')]
        [string]$Tooltip
    )

    "New [CompletionResult]: $CompletionText, $ListItemText, $ResultType, $Tooltip" | Write-Debug

    [CompletionResult]::new( $CompletionText, $ListItemText, $ResultType, $Tooltip)
    return
}

# $_privateExeName = 'dotnet'
Register-ArgumentCompleter -Native -CommandName 'dotnet' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'dotnet'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-')) {
                break
            }
            $element.Value
        }) -join ';'

    $completions = @(switch ($command) {
            'dotnet' {
                # todo: refactor to import from user JSON, or [Hashtable]
                New-CompletionResult '--info' 'info' ParameterName 'Display Runtime Environment, Host, SDKs installed and runtimes installed'
                New-CompletionResult '--list-sdks' 'list-sdks' ParameterName 'List installed SDKs'
                New-CompletionResult '--list-runtimes' 'list-runtimes' ParameterName 'List installed runtimes'
                New-CompletionResult '--diagnostics' 'diagnostics' ParameterName 'Enable diagnostic output.'



                # [CompletionResult]::new('--list-sdks', 'zebra', [CompletionResultType]::ParameterName, 'Prints help information. Use --help for more details.')
                # [CompletionResult]::new('--help', 'help', [CompletionResultType]::ParameterName, 'Prints help information. Use --help for more details.')
                # [CompletionResult]::new('-V', 'V', [CompletionResultType]::ParameterName, 'Prints version information')
                # [CompletionResult]::new('--version', 'version', [CompletionResultType]::ParameterName, 'Prints version information')
                break
            }
        })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
    Sort-Object -Property ListItemText
}
