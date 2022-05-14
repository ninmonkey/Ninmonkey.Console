#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'ZD-Format-PropsToDefinition'
    )
    $publicToExport.alias += @(
        # 'a' # 'ZD-Format-PropsToDefinition'
    )
}

function ZD-Format-PropsToDefinition {
    <#
    .synopsis
        more of a cantrip than a function
    .example
        propsToLiteral $one | bat -fpl ps1
    #>
    param(
        [object]$Target
    )
    # | Sort-Object { ($_.Value)?.GetType() ?? '[␀]' }
    $Target.psobject.properties
    | Sort-Object Name
    | Sort-Object { ($_.Value)?.GetType() }
    | Join-String -sep "`n" {
        '[{0}]${1}{2}' -f @(
            # ($_.Value)?.GetType() ?? '[␀]'
            $_.TypeNameOfValue
            # actually typenameofvalue is the static type
            $_.Name
        )
        | Join-String -sep "`n"
    }
}
