
function ConvertTo-Timespan {
    <#
    .synopsis
        converts fuzzy dates to a [datetime]
    .description
        minimal error detection, or some defaults apply less impact
        ex: Without strict mode, if the $RelativeText has extra data
            after splitting, then there's an error.
        new:
            - throw errors when no value is created, user may ignore it.


        future:
            decent deterministic error dectection is
                1] attempt to grab matches in the orignal string:
                    "[day]? [hour]? [minute]? [second]?"
                2] strip those matches from the original string
                3] if orignal string.length > 0,
                    throw error

            that covers the majority of error cases,
            without complex logic or edge cases

    .example
        1d3h4s -> #duration(1, 3, 4)'
    .outputs
        [timespan] or null
    .notes
        futrue:
        - [ ] better verb?
            better name, timespan? ConvertTo ?
            'New-RelativeTimespan' or 'ConvertTo-Timespan' ?

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
            (?<Days>\-?\d+)
        d)?
        (
            (?<Hours>\-?\d+)
        h)?
        (
            (?<Minutes>\-?\d+)
        m)?
        (
            (?<Seconds>\-?\d+)
        s)?
        (
            (?<Milliseconds>\-?\d+)
        ms)?
        (?<Rest>.*)
        $
'@
    }
    process {
        try {
            # todo: If anything is **not captured**, ie: the unmatched length is > 0
            # then throw a parse error
            if (!($RelativeText -match $Regex.ParseString)) {
                Write-Error "Failed parsing string '$RelativeText'" -Category InvalidArgument
                return
            }

            $Days = $Matches.Days ?? 0
            $Hours = $Matches.Hours ?? 0
            $Minutes = $Matches.Minutes ?? 0
            $Seconds = $Matches.Seconds ?? 0
            $Milliseconds = $Matches.Milliseconds ?? 0

            $Days, $Hours, $Minutes, $Seconds, $Milliseconds
            | Join-String -sep ', ' | Label 'Args' | Write-Debug


            $ts = [timespan]::new($Days, $Hours, $Minutes, $Seconds, $Milliseconds)
            if ($ts -eq 0 -or $null -eq $ts) {
                # write-debug '[timespan] == 0'
                # Do I want to opt in or out?
                if (! $ZeroIsValid) {
                    $splatError = @{
                        ErrorAction = 'Stop'
                    }
                }
                Write-Error '[timespan] == 0' -TargetObject $RelativeText @splatError
            }
            $ts
        }
        catch {
            Write-Error -Message "Failed parsing string '$RelativeText'" -ErrorRecord $_
            # throw [System.MissingFieldException]::new('Could not access field', $_.Exception)
        }
    }
}

# hr 2
# RelativeTs '3' -ea break
# RelativeTs '0'
