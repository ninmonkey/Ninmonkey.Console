function Trace-NinCommand {
    <#
    .description
        still a WIP, need to crate better temp files
        - writes two logs, one without cleanup
        - auto opens both or none

        first try these:
            PS> Trace-NinCommand -Expression $sb -AutoOpen
            PS> Trace-NinCommand -Expression $sb

        # to compare log before and after filtering, run:

            PS> Trace-NinCommand -Expression { ls . } -WithOriginal -AutoOpen
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
    .example
        # when logs auto-open, include the original trace file as well
        Trace-NinCommand -Expression $sb -WithOriginal -AutoOpen
    .example
        # only print to stdout, no opening log
        Trace-NinCommand -Expression $sb
    .example

        # no stdout, opens filtered
        PS> Trace-NinCommand -Expression $sb -Silent -AutoOpen

    #>
    [CmdletBinding()]
    param(
        # ScriptBlock to run
        [Parameter(Mandatory)]
        [scriptblock]$Expression,

        # do not print results to StdOut
        [Parameter()][switch]$Silent,

        # open filtered log automatically ?
        [Parameter()][switch]$AutoOpen,

        # open original log automatically ?
        [Parameter()][switch]$WithOriginal,

        # ignore syntax highlighting, (requires python package 'Pygments')
        [Parameter()][switch]$NoColor
    )


    $Regex = @{
        StripPrefix  = [regex]::Escape( 'ParameterBinding Information: 0 : ' )
        TypeNameList = @(
            '(System\.Management\.Automation\.?)'
            '(Microsoft\.Powershell\.Commands\.?)'
        ) | Sort-Object -Descending
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

    $replaceWith = 'abbr.' # namespace adds nighlighting if at least 1 '.'
    Get-Content $Paths.ExportPath | ForEach-Object {

        $cur = $_
        $cur = $cur -replace $Regex.StripPrefix, ''

        foreach ($tName in $Regex.TypeNameList ) {
            $cur = $cur -replace $tName, $replaceWith
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

    if (! $Silent ) {
        if (! $NoColor) {
            $RegexQuote = "\b\'\b"

            Get-Content $Paths.ExportFilter
            | ForEach-Object { $_ -replace $RegexQuote, "''" }
            | pygmentize.exe -l ps1

        } else {
            Get-Content $Paths.ExportFilter
        }
    }
    if ( $AutoOpen) {
        if ($WithOriginal) {
            Invoke-Item $Paths.ExportPath
        }
        Invoke-Item $Paths.ExportFilter
    }


    Write-Information "Wrote to files: "
    Write-Information $Paths.ExportPath.FullName
    Write-Information $Paths.ExportFilter.FullName

    # code $ExportPath
    # } -Debug -Verbose -PSHost *>&1 | Set-Content -Path "temp:\codeout"
    # $ExportPath
}


# $sb = {
#     wipNew-CompletionResult '/showclassid6', '/ShowClassId6', [CompletionResultType]::ParameterName, 'display'
# }
# Trace-NinCommand -Expression $sb
if ($false) {
    $sb = {
        Join-String -InputObject ('a', 'b') -Separator '-'
    }

    $sb = {
        '.' | Get-ChildItem -File
    }
    Trace-NinCommand -Expression $sb
    # examples:
    Trace-NinCommand -Debug -Verbose -Expression $sb
    Trace-NinCommand -Debug -Verbose -Expression $sb -PassThru

}