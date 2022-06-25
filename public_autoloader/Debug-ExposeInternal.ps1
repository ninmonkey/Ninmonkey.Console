if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'Debug-ExposeInternalItem'
    )
    $script:publicToExport.alias += @(
        'Debug-InModuleScope' # 'Debug-ExposeInternalItem'

    )
}


function Debug-ExposeInternalItem {
    <#
    .SYNOPSIS
        sugar for: & (get-module Ninmonkey.Console ) { [WrapStyle] }
    .NOTES
        should I use =iex or anything crazy here?
        maybe I can instead ask for autocompletions using that scope?

        works when manually used, but not when invoked frm a module
    .example
        Debug-InModuleScope -ModuleName Ninmonkey.Console -Expression { [WrapStyle] }
    #>
    [Alias(
        'Debug-InModuleScope',
        'Debug->InModuleScope'

    )]
    [IsExperimental('Works outside, needs a different invoke style for invoking this  in-module')]
    [CmdletBinding()]
    param(
        # todo: argument completer using the attribute arguments
        # for inline type
        [ArgumentCompletions(
            'Ninmonkey.Console', 'Dev.Nin',
            'PSReadLine',
            'ClassExplorer',
            'pslambda', 'functional',
            'Utility',
            'ugit',
            'PSReadLine',
            'pslambda',
            'Pansies',
            'Microsoft.PowerShell.Utility',
            'Microsoft.PowerShell.Management',
            'CompletionPredictor'
        )]
        [Parameter(Mandatory, Position = 0)]
        [String]$ModuleName,

        [ArgumentCompletions('{ [WrapStyle] }')]
        [Parameter(Mandatory, Position = 1)]
        [ScriptBlock]$Expression
    )

    & (Get-Module -Name $ModuleName ) { $ScriptBlock }

    # & (Get-Module -Name $ModuleName -ListAvailable | Select-Object -First 1) {
    #     $Expression
    # }

}
