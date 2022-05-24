
function ConvertTo-Timespan {
    <#
    .synopsis
        converts strings to a [timespan]
    .description
        by default the value 0 is an error, or when the regex does not match
        throw errors when no value is created, user may ignore it.

        next: force a full regex match, $RelativeText has any non-matched text,
            after splitting, then there's an error.
            next: decent deterministic parse decetection is
                1] attempt to grab matches in the orignal string:
                    "[day]? [hour]? [minute]? [second]?"
                2] strip those matches from the original string
                3] if non-matching string.length > 0,
                    throw error

                that covers the majority of error cases, without complex logic or edge cases

    .example
        1d3h4s -> #duration(1, 3, 4)'
    .example
        PS>  $tslist = @(
            2 | days
            3 | hours
        )

        $ts_sum = $tslist | Measure-Object TotalMilliSeconds -Sum | % Sum | %{
            [timespan]::new(0,0,0,0,$_)
        }

        $ts_sum | Should -be (RelativeTs 2d3h -debug)

        $tslist = @(
            2 | days
            3 | hours
        )

        $total_ms = $tslist | Measure-Object TotalMilliSeconds -Sum | % Sum

        $ts_sum = $total_ms  | %{
          [timespan]::new(0,0,0,0,$_)
        }

        $ts_sum | Should -be (RelativeTs 2d3h)
    .outputs
        [timespan] or null
    .notes
        - [ ] better verb?
            better name, timespan? ConvertTo ?
            'New-RelativeTimespan' or 'ConvertTo-Timespan' ?



        See also: Szeraax/Get-TimeStuff.ps1
    .link
        https://gist.github.com/Szeraax/43aa193e0759d9b091faaaa2f5a03cc9

    #>
    [cmdletbinding( PositionalBinding = $false)]
    [Alias('RelativeTs')] # 'New-RelativeTimespan' ?\
    [OutputType( [TimeSpan] )]
    param(
        # relative string, ex: 1d3h4s
        [Parameter(Position = 0, Mandatory)]
        [string]$RelativeText,

        # don't throw an error when it evaluates to zero  (like a silent parse fail RelativeTs 'azfefj')
        [ALias('AllowZero')]
        [Parameter()][switch]$ZeroIsValid
    )

    begin {
        $Regex ??= @{}
        $Regex.ParseString = @'
(?x)
        ^
        (
            (?<Days>[\d\.\-]+)
            d
        )?
        (
            (?<Hours>[\d\.\-]+)
            h
        )?
        (
            (?<Minutes>[\d\.\-]+)
            m
        )?
        (
            (?<Seconds>[\d\.\-]+)
            s
        )?
        (
            (?<Milliseconds>[\d\.\-]+)
            ms
        )?

        (?<Rest>.*)
        $
'@
    }
    process {
        try {
            # todo: If anything is **not captured**, ie: the unmatched length is > 0
            # then throw a parse error
            if (!($RelativeText -match $Regex.ParseString)) {
                Write-Error -m "Failed parsing string '$RelativeText'" -Category InvalidArgument
                return
            }

            $Days = $Matches.Days ?? 0
            $Hours = $Matches.Hours ?? 0
            $Minutes = $Matches.Minutes ?? 0
            $Seconds = $Matches.Seconds ?? 0
            $Milliseconds = $Matches.Milliseconds ?? 0

            $Days, $Hours, $Minutes, $Seconds, $Milliseconds
            | Join-String -sep ', ' -op 'Timespan args: ' | Write-Debug

            $ts = [timespan]::new($Days, $Hours, $Minutes, $Seconds, $Milliseconds)
            if ($ts -eq 0 -or $null -eq $ts) {
                # $splatError = @{}
                # if (! $ZeroIsValid) {
                #     $splatError = @{
                #         ErrorAction = 'Stop'
                #     }
                # }
                # Write-Error -m '[timespan] == 0' -TargetObject $RelativeText @splatError
            }
            $ts
        } catch {
            Write-Error -Message "Failed parsing string '$RelativeText'" -Category 'InvalidData'
            # throw [System.MissingFieldException]::new('Could not access field', $_.Exception)
        }
    }
}
