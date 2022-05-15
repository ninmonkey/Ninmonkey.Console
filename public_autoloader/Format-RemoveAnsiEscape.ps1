#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Format-RemoveAnsiEscape'
    )
    $publicToExport.alias += @(
        'StripAnsi' # 'Format-RemoveAnsiEscape'
        'Remove-AnsiEscape' # 'Format-RemoveAnsiEscape'
    )
}

#move to console, now #8
function Format-RemoveAnsiEscape {
    <#
    .synopsis
        strips ansi colors (or optionally, all ansi control sequences)
    .notes
        update by (also) Jaykul
        > Technically, I think '\u001B.*?\p{L}' is ok, but '\u001B.*?m' is not,
        > because it would match on any escape sequence, provided there was an m later.
        > You'd need '\u001B\[[^\p{L}]*?m' or '\u001B\[.*?\p{L}(<=m)
            <https://discord.com/channels/180528040881815552/447475598911340559/971943112995922050>

    #>

    [Alias('StripAnsi', 'Remove-AnsiEscape')]
    [cmdletbinding()]
    param(
        [Alias('Text')]
        [AllowNull()]
        [AllowEmptyString()]
        [parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$InputObject,

        # misc label
        [alias('All')]
        [switch]$StripEverything
    )
    begin {
        # Regex from Jaykul
        $Regex = @{
            StripColor = '\u001B.*?m'
            StripAll   = '\u001B.*?\p{L}'
        }
        # I use that for stripping escape sequences so I can measure string length
        # But it removes everything
        # if you wanted just color stuff, you might put m instead of \p{L}

    }
    process {
        if ($null -eq $InputObject) {
            return
        }
        if ($StripEverything) {
            $InputObject -replace $Regex.StripAll, ''
        } else {
            $InputObject -replace $Regex.StripColor, ''
        }

    }
}
