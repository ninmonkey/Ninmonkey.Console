function Trace-NinCommand {
    <#

    .notes

        future params:
           -Option

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0,
            HelpMessage = "ScriptBlock to run")]
        [scriptblock]$Expression,

        [Parameter(HelpMessage = "return text to console")][switch]$Silent,

        [Parameter(HelpMessage = "return text to console")][switch]$PassThru
    )


    $Regex = @{
        DefaultStrip = 'ParameterBinding Information: 0 :'
    }


    # $ExportPath = 'temp:\lasttrace-output.log'
    $ExportPath = 'C:\Users\cppmo_000\AppData\Local\Temp\LastTrace-output.log'
    $traceCommandSplat = @{
        Name       = 'parameterbinding'
        Debug      = $true
        Verbose    = $true
        # PSHost     = $true
        FilePath   = $ExportPath
        Expression = $Expression
    }
    [pscustomobject]$traceCommandSplat
    | Format-Table | Out-String -w 9999 | Write-Debug

    Trace-Command @traceCommandSplat

    if ($PassThru) {
        Get-Content $ExportPath
        return
    }

    Get-Content $ExportPath | ForEach-Object {
        $_ -replace $Regex.DefaultStrip, ''
    }


    # code $ExportPath
    # } -Debug -Verbose -PSHost *>&1 | Set-Content -Path "temp:\codeout"
    # $ExportPath
}


$sb = {
    wipNew-CompletionResult '/showclassid6', '/ShowClassId6', [CompletionResultType]::ParameterName, 'display'
}
Trace-NinCommand -Expression $sb

# examples:
if ($false) {
    Trace-NinCommand -Debug -Verbose -Expression $sb
    Trace-NinCommand -Debug -Verbose -Expression $sb -PassThru

}