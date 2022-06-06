#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Debug-CompareVariablesInModule'
    )
    $publicToExport.alias += @(
        'Debug->DeltaVariable' # 'Debug-CompareVariablesInModule'
    )
}

function Debug-CompareVariablesInModule {
    <#
    .SYNOPSIS
        what's unique to local vs module scope?
    .example
        Debug-CompareVariablesInModule ClassExplorer
    .example
        Debug-CompareVariablesInModule ClassExplorer -PassThru
    #>
    [Alias('Debug->DeltaVariable')]
    param(
        [ArgumentCompletions('Ninmonkey.Console', 'Dev.Nin')]
        [Parameter(Mandatory, Position = 0)]
        [string]$ModuleName = 'Ninmonkey.Console',
        [switch]$PassThru
    )

    $Names = @{}
    $Names.Local = & (Get-Module $ModuleName ) { Get-Variable -Scope 0 } | ForEach-Object Name
    $Names.Module = & (Get-Module $ModuleName ) { Get-Variable -Scope 1 } | ForEach-Object Name
    if ( $PassThru ) {
        return $Names
    }
    foreach ($item in $Names.Module) {
        if ($item -notin $Names.Local) {
            $item
        }
    }
}

