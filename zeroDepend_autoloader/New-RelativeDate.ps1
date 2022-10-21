using namespace System.Collections.Generic
# uses pansies # soft,to prevent the requirement

if ( $publicToExport ) {
    $publicToExport.function += @(
        'New-RelativeDate'
    )
    $publicToExport.alias += @(
        'RelativeDt' # 'New-RelativeDate'
        # 'RelDt'
        # 'TimeBefore'
        # 'TimeAfter'

    )
}



function New-RelativeDate {
    <#
    .synopsis
        creates a [Datetime] using relative strings
    .description


    .example
        PS>
    .outputs
        [Datetime]
    .notes
        I'm not sure what kind of syntax I want
        below was implicity datetimes as outpupt

        see: <file:///C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github\Ninmonkey.Console\public\ConvertTo-Timespan.ps1>


        ## Ideas of possible syntaxes

            $files  | RelativeDt -newerThan 3day

            RelativeDt -newerThan 3d $files

            2h ago
            last 2h
            since 2h

            RelTime 2h -before $target
            RelTime 2h -after $target

            RelTime -2h

                now -2h

            RelTime  2h

                now  +2

        ## I really like 'fd'-finds syntax

            fd --changed-within 4minutes --search-path (get-item $Env:AppData)

            --changed-within <date|dur>
                Filter results based on the file modification time. The argument can be provided as a
                specific point in time (YYYY-MM-DD HH:MM:SS) or as a duration (10h, 1d, 35min). If the
                time is not specified, it defaults to 00:00:00. '--change-newer-than' or '--newer' can
                be used as aliases.
                Examples:
                    --changed-within 2weeks
                    --change-newer-than '2018-10-27 10:00:00'
                    --newer 2018-10-27

            --changed-before <date|dur>
                Filter results based on the file modification time. The argument can be provided as a
                specific point in time (YYYY-MM-DD HH:MM:SS) or as a duration (10h, 1d, 35min).
                '--change-older-than' or '--older' can be used as aliases.
                Examples:
                    --changed-before '2018-10-27 10:00:00'
                    --change-older-than 2weeks
                    --older 2018-10-27



        See also: Szeraax/Get-TimeStuff.ps1 (gist)
    .link
        Ninmonkey.Console\ConvertTo-Timespan
    .link
        https://gist.github.com/Szeraax/43aa193e0759d9b091faaaa2f5a03cc9

    #>
    [cmdletbinding()]
    [Alias(
        'RelativeDt'
        # 'RelativeDate',
        # 'RelDt',
        #  'TimeBefore', 'TimeAfter'
    )] # 'New-RelativeTimespan' ?\
    [OutputType( [Datetime] )]
    param(
        # relative string, ex: 1d3h4s
        [Parameter(Position = 0, Mandatory)]

        # print a cheat sheet of options
        [switch]$Help,
        [string]$RelativeText,

        # last modified time by default
        [Alias('OlderThan', 'Before')]
        [ArgumentCompletions(
            '5s', '5seconds',

            '4m', '4minutes',
            '4min', #
            '2d', '4days',
            '3Months2d1h4m3s25ms',

            '2M', '2Months',
            '2w', '2weeks',
            '2018-10-27',
            '2018-10-27 10:00:00'

        )]
        [string]$ChangedBefore = '<date|duration>',

        # todo: implement arg transformation attribute
        # that maps to fuzzy relative date parameters
        # todo: automated regex testing
        [ArgumentCompletions(
            'Today', 'Yesterday', 'Tomorrow',
            'LastWeek', 'NextWeek', 'ThisWeek',
            'LastYear', 'NextYear', 'ThisYear'
        )]
        [string]$FuzzyRelative,

        # last modified time by default
        [Alias('NewerThan', 'After')]
        [string]$ChangedWithin = '<date|duration>',

        # auto coerces files to date modified if not specified
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('RelativeTo', 'Target', 'Reference', 'InputObject', 'LastWriteTime')]
        [object]$ReferenceObject

        # don't throw an error when it evaluates to zero  (like a silent parse fail RelativeTs 'azfefj')
        # [ALias('AllowZero')]
        # [Parameter()][switch]$ZeroIsValid
    )

    begin {
        if($Help -or $RelativeText -or $ChangedBefore -or $ChangedWithin -or $FuzzyRelative -or $Before) {
            throw "NYI"
        }


        throw "NYI"

        $Regex ??= @{}
        $Regex.ParseString = @'
(?x)
        ^
    # capture assumes fields are in descending order


        (
            (?<Weeks>[\d\.\-]+)
            (y|years)
        )?
        (
            (?<Month>[\d\.\-]+)

            # Because I wanted case insensitive
            (Mon|Months)
        )?
        (
            (?<Weeks>[\d\.\-]+)
            (w|weeks)
        )?
        (
            (?<Days>[\d\.\-]+)
            (d|days)
        )?
        (
            (?<Hours>[\d\.\-]+)
            (h|hours)
        )?
        (
            (?<Minutes>[\d\.\-]+)
            (Minutes|min|m)
        )?
        (
            (?<Seconds>[\d\.\-]+)
            (seconds|secs|s)
        )?
        (
            (?<Milliseconds>[\d\.\-]+)
            (milliseconds|ms)
        )?

        (?<Rest>.*)
        $
'@
    }
    process {
        if ( -not ($RelativeText -match $Regex.ParseString)) {
            Write-Error -ea 'stop' -m "Failed parsing string '$RelativeText'" -Category InvalidArgument
            return
        }
        $matches.remove(0)
        $tokens = [pscustomobject]$Matches
        $tokens | to->json | write-debug

        try {
            # todo: If anything is **not captured**, ie: the unmatched length is > 0
            # then throw a parse error

            $Reference = $Targf

            if($false -and 'old') {
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
            }
        } catch {
            Write-Error -Message "Failed parsing string '$RelativeText'" -Category 'InvalidData'
            # throw [System.MissingFieldException]::new('Could not access field', $_.Exception)
        }
    }
}
