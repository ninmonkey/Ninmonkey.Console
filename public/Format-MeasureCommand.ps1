
function Format-MeasureCommand {
    <#
    .Synopsis
        Improves readability of multiple 'measure-command's

    .Description

        todo:
            - [ ] arg as array, or hashtable arg
            - [ ] show speedups as relative percents of best/worst
            - [ ] -retry count: measure scriptblock multiple times

    .example
        PS> $results = @(
            measure-command { 0.. 200 },
            measure-command { 0.. 200 },
            measure-command { 0.. 200 },
        )
        Format-MeasureResults $results

    .example
        PS> Format-MeasureResults -ScriptBlock { 0..300 | sort }
    .example
        PS> $results = [ordered]@{}

        $results['convert csv'] = measure-command {
            ls | ConvertTo-Csv
        }

        $results['convert json'] = measure-command {
            ls | ConvertTo-Json
        }

        Format-MeasureResults $results


    .example
        ps> Format-MeasureResults $results

        Id  TotalMs Test
        --  ------- ----
        3 717.9803 2**16: out: join-stri
        2 516.9105 2**16: out: -join '',
        1 469.9436 2**16: out: pipeline,
        0   3.4769 256: Naive string-joi
        4   2.3224 c

    #>
    Param([hashtable]$results)
    $id = 0
    $results.Keys | ForEach-Object {
        $key = $_
        [pscustomobject][ordered]@{
            Test      = $key
            Ms        = $results.$key.Milliseconds
            MsConvert = $results.$key.Milliseconds -as 'int'
            TotalMs   = $results.$key.TotalMilliseconds
            Id        = $id++
        }
    } | Sort-Object TotalMs -Descending
    | Format-Table Id, TotalMs, Test

    hr
}
