
function ConvertTo-Timespan {
    <#
    .synopsis
        converts fuzzy dates to a [datetime]
    .description
        minimal error detection.
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
    [cmdletbinding()]
    [Alias('RelativeTs')] # 'New-RelativeTimespan' ?
    param(
        # relative string, ex: 1d3h4s
        [Parameter(Position = 0, Mandatory)]
        [string]$RelativeText
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
        if (!($RelativeText -match $Regex.ParseString)) {
            Write-Error "Failed parsing string '$RelativeText'"
            return
        }

        $Days = $Matches.Days ?? 0
        $Hours = $Matches.Hours ?? 0
        $Minutes = $Matches.Minutes ?? 0
        $Seconds = $Matches.Seconds ?? 0
        $Milliseconds = $Matches.Milliseconds ?? 0

        $Days, $Hours, $Minutes, $Seconds, $Milliseconds
        | Join-String -sep ', ' | Label 'Args' | Write-Debug

        try {

            $ts = [timespan]::new($Days, $Hours, $Minutes, $Seconds, $Milliseconds)
            $ts
        }
        catch {
            Write-Error "Failed parsing string '$RelativeText'"
            # throw [System.MissingFieldException]::new('Could not access field', $_.Exception)
        }
    }
}
