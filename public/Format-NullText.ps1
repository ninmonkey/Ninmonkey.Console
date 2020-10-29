
function Format-NullText {
    <#
    .synopsis
        format null values to be human readable
    .description
        turns $null values, and null unicode in strings
    #>
    param(
        [Parameter(
            Mandatory, Position = 0,
            ValueFromPipeline, HelpMessage = "piped objects, possible null")]
        [AllowNull()]
        # Not actually text, but,
        [object]$InputObject,

        [Parameter(
            Position = 1,
            HelpMessage = "String to use if not the default")]
        [string]$ReplacementString = '␀'
    )
    begin {
        $Uni = @{
            Null       = "`u{0}"
            NullSymbol = '␀'
        }

    }

    process {
        # Either symbol for null, if text then replace null values
        if ($null -eq $InputObject) {
            return $Uni.NullSymbol
        }

        if ($InputObject -is 'String') {
            $FilteredString = $InputObject -replace $uni.Null, $uni.NullSymbol
            $FilteredString
            return
        }

        return $InputObject
    }
}
