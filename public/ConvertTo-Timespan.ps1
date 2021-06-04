
function ConvertTo-Timespan {
    <#
    .synopsis
        converts fuzzy dates to a [datetime]
    .example
        1d3h4s -> #duration(1, 3, 4)'
    .outputs
        [timespan] or null
    .notes
        better verb? better name, timespan?
        ConvertTo ?
    #>
    [cmdletbinding()]
    [Alias('RelativeTs')]
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

# ConvertTo-Timespan '3asf'
# ConvertTo-Timespan '3h1ms'