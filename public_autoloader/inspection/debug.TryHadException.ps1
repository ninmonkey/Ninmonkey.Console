#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'try.hadException?'
    )
    $publicToExport.alias += @(
        # '' # 'try.hadException?'
    )
}

function try.hadException? { 
    <#
    .SYNOPSIS
        ToastIfy: Quickly test module changes, ensuring a new import dfoes not fail
    .description
        A quick hack. Future: Import test should run in a local env.
        maybe using a runspace
    .depends
        ToastIt
    .EXAMPLE
        try.hadException? Ninmonkey.Console { 0..5 | Join.UL }
    #>
    param( 
        [Parameter()][ArgumentCompletions(
            'Ninmonkey.Console', 'Ninmonkey.Console, PipeScript')]
        [string]$ModuleImports = 'Ninmonkey.Console',

        [ArgumentCompletions('{ 0..5 | Join.UL }')]
        [ScriptBlock]$ScriptBlock ) 

    #  Import-Module -Scope Global 
    # & {
    Import-Module -Name $ModuleImports -Force -wa SilentlyContinue
    $lastErrorsInMyScope = $Error.count
    $didThrow? = $false
    try {
        & $ScriptBlock #3>&1 *>$null | out-null
    }
    catch { $didThrow? = $true }
    $errDelta = $error.count - $lastErrorsInMyScope

    "Modules: $($ModuleImports -join ', ' )"
    | write-verbose

    $semIcon = @{
        StateSuccess = '✅'
        StateFail    = '⛔'
        Good         = '👍'
        Bad          = '👎'
        Pin          = '📌'
    }
    $finalTitle = @'
Try Import => {0}
'@ -f @(    
        $DidThrow? ? $semIcon.StateGood : $semIcon.StateFail
    )
    $finalMessage = @"
    Did throw? {1}
    Err Delta: {2}
${DidThrow?}        
"@ -f @( 
        $DidThrow? ? $semIcon.Bad : $semIcon.Good
        $didThrow?
        $errDelta
    )
    ToastIt -Title $finalTitle $finalMessage
    if ($errDelta -gt 0 ) {
        $finalTitle | write-error 
        $finalTitle | write-error
    }
}