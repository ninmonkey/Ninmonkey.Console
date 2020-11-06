function Trace-NinCommand {
    <#
    .description
        still a WIP, need to crate better temp files
        - writes two logs, one without cleanup
        - auto opens both or none
    .notes

        future todo:
            - [ ] params: -Option
            - [ ] parse log lines to PSCustomObject instead of removal

    .example
        PS> Trace-NinCommand -Debug -Verbose -Expression $sb
        # prints output to console
    .example
        PS>
        # writes output to a log
        $sb = {
            Join-String -InputObject ('a', 'b') -Separator '-'
        }

        Trace-NinCommand -Debug -Verbose -Expression $sb
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
            HelpMessage = "ScriptBlock to run")]
        [scriptblock]$Expression,

        [Parameter(HelpMessage = "do not print results to StdOut")][switch]$Silent,

        [Parameter(HelpMessage = "returns non-filtered text")][switch]$PassThru,
        # [Parameter(HelpMessage = "removes common namespaces")][switch]$Minimize,
        [Parameter(HelpMessage = "do not open log automatically")][switch]$NoAutoOpen


        # [Parameter(HelpMessage = "Formatting options")]
        # [ValidateSet('Default', 'MiniType')]
        # [string[]]$Mode = 'Default'
    )


    $Regex = @{
        StripPrefix  = [regex]::Escape( 'ParameterBinding Information: 0 : ' )
        # MiniTypes    = '(?<=\[)(System\.Management\.?)'

        TypeNameList = @(
            # '\bSystem\.Management\.Automation\.'
            # '(?<=\[?)(System\.Management\.Automation\.?)'

            '(?:\[?)(System\.Management\.Automation\.?)'

        )
    }


    # $ExportPath = 'temp:\lasttrace-output.log'
    $Paths = @{
        ExportPath   = "$env:LocalAppData\Temp\LastTrace-output.log"
        ExportFilter = "$env:LocalAppData\Temp\LastTrace-output.filter.log"
    }

    Set-Content -Path $Paths.ExportPath -Value '' # probably redundant

    $traceCommandSplat = @{
        Name       = 'parameterbinding'
        Debug      = $true
        Verbose    = $true
        FilePath   = $Paths.ExportPath
        Expression = $Expression
        # PSHost     = $true
    }
    [pscustomobject]$traceCommandSplat
    | Format-List | Out-String -w 9999 | Write-Debug

    Trace-Command @traceCommandSplat | Out-Null

    if ($PassThru) {
        Get-Content $Paths.ExportPath
        return
    }

    Get-Content $Paths.ExportPath | ForEach-Object {
        $cur = $_
        $cur = $cur -replace $Regex.StripPrefix

        foreach ($tName in $Regex.TypeNameList ) {
            $cur = $cur -replace $tName, ''
        }

        $cur



        # switch ($Mode) {
        #     'Minitypew' {
        #         $cur -replace $Regex.MiniTypes, ''
        #         break
        #     }
        #     'Default' {
        #         $cur = $_ -replace $Regex.StripPrefix
        #         break
        #     }
        #     default {

        #     }
        # }
    }  | Set-Content -Path $Paths.ExportFilter

    if (! $NoAutoOpen) {
        Invoke-Item $Paths.ExportPath
        Invoke-Item $Paths.ExportFilter
    }

    # code $ExportPath
    # } -Debug -Verbose -PSHost *>&1 | Set-Content -Path "temp:\codeout"
    # $ExportPath
}


# $sb = {
#     wipNew-CompletionResult '/showclassid6', '/ShowClassId6', [CompletionResultType]::ParameterName, 'display'
# }
# Trace-NinCommand -Expression $sb
$sb = {
    Join-String -InputObject ('a', 'b') -Separator '-'
}

Trace-NinCommand -Expression $sb
# examples:
if ($false) {
    Trace-NinCommand -Debug -Verbose -Expression $sb
    Trace-NinCommand -Debug -Verbose -Expression $sb -PassThru

}