
#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-JsonJqQuery' # 'Ninmonkey.Console\Json.JqQuery'
    )
    $publicToExport.alias += @(
        'Json.JqQuery' # Ninmonkey.Console\Invoke-JsonJqQuery
    )
    $publicToExport.variable += @(

    )
}
function Invoke-JsonJqQuery {
    <#
    .SYNOPSIS
        minimal Jq Query base template for args
    .EXAMPLE
        Import-Module uGit -ea 'stop'
        git status | Invoke-JsonJqQuery

    .NOTES
    jq - commandline JSON processor [version 1.6]

            Usage:  C:\ProgramData\chocolatey\lib\jq\tools\jq.exe [options] <jq filter> [file...]
                    C:\ProgramData\chocolatey\lib\jq\tools\jq.exe [options] --args <jq filter> [strings...]
                    C:\ProgramData\chocolatey\lib\jq\tools\jq.exe [options] --jsonargs <jq filter> [JSON_TEXTS...]

            jq is a tool for processing JSON inputs, applying the given filter to
            its JSON text inputs and producing the filter's results as JSON on
            standard output.

            The simplest filter is ., which copies jq's input to its output
            unmodified (except for formatting, but note that IEEE754 is used
            for number representation internally, with all that that implies).

            For more advanced filters see the jq(1) manpage ("man jq")
            and/or https://stedolan.github.io/jq

            Example:

                    $ echo '{"foo": 0}' | jq .
                    {
                            "foo": 0
                    }

            Some of the options include:
            -c               compact instead of pretty-printed output;
            -n               use `null` as the single input value;
            -e               set the exit status code based on the output;
            -s               read (slurp) all inputs into an array; apply filter to it;
            -r               output raw strings, not JSON texts;
            -R               read raw strings, not JSON texts;
            -C               colorize JSON;
            -M               monochrome (don't colorize JSON);
            -S               sort keys of objects on output;
            --tab            use tabs for indentation;
            --arg a v        set variable $a to value <v>;
            --argjson a v    set variable $a to JSON value <v>;
            --slurpfile a f  set variable $a to an array of JSON texts read from <f>;
            --rawfile a f    set variable $a to a string consisting of the contents of <f>;
            --args           remaining arguments are string arguments, not files;
            --jsonargs       remaining arguments are JSON arguments, not files;
            --               terminates argument processing;

            Named arguments are also available as $ARGS.named[], while
            positional arguments are available as $ARGS.positional[].
    #>
    [Alias('Json.JqQuery')]
    [CmdletBinding()]
    param(
        [ArgumentCompletions(
            "'keys'", "'.'"
        )]
        [Parameter(Mandatory)]
        [string]$Query
    )
    Write-Warning 'finish:
        make as a steppable query so that you can process jq as a document per-line
        instead of one giant json document'

    $binJq = Get-Command -CommandType Application -path 'jq' -ea stop | Select-Object -First 1
    [Collections.Generic.List[Object]]$binArgs = @(
        #
        $Query
    )
    $stat = git status # ugit
    $stat | json -Depth 1
    | & $binJq @BinArgs

    <#
    original:

        function Invoke-JsonJqQuery {
            throw 'finish: make as a steppable query that can iinvoke per-line or per-entire-pipeline was a steppable query ma'
            $stat | json -Depth 1 | jq 'keys'
        }

        git status | Invoke-JsonJqQuery

    #>
}

