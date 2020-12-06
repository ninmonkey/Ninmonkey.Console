
function Format-NullText {
    <#
    .synopsis
        format null values to be human readable
    .description
        turns $null values, and null unicode in strings
    #>
    param(
        # piped objects, allows null
        # Not actually text, but,
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [AllowNull()]
        [object]$InputObject,

        # safe String to use if not the default
        [Parameter(Position = 1)]
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
