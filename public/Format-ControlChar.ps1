#requires -Version 7.0

# function Format-ControlChar2 {
#     <#
#     .SYNOPSIS
#         replace control chars with safe-to-print-or-pipe symbols. simpler variant of Format-ControlChar
#     .DESCRIPTION
#         the 'trick' is add 0x2400 to the codepoint forr the safe symbol version
#     .notes
#         Here is the full block

#             format unicode strings, making them safe.
#             Null is allowed for the user's conveinence.
#             allowing null makes it easier for the user to pipe, like:
#             'gc' without -raw or '-split' on newlines
#         .LINK
#             https://www.compart.com/en/unicode/block/U+0000
#         .link
#             https://www.compart.com/en/unicode/block/U+2400
#         #>
#     param(
#         # makes piping from gc or anything not spam errors
#         [Alias('Text', 'Lines')]
#         [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
#         [AllowNull()]
#         [AllowEmptyCollection()]
#         [AllowEmptyString()]
#         [string[]]$InputText,

#         # extra options
#         [Parameter()][hashtable]$Options

#     )
#     begin {

#     }
#     process {
#         foreach($Line in $InputText)  {
#             $Line.EnumerateRunes() | %{
#                 if($_.Value -le 0x20) {
#                     [Text.Rune]::new($_.Value + 0x2400)
#                     return
#                 }
#                 return $_
#             }
#         }
#     }
#     end {}
# }

function Format-ControlChar {
    <#
    .synopsis
        Converts unsafe control chars to their symbols, making it safe to display
    .description
        Replaces C0-control codes with their unicode-symbol replacents at u+2400+

        - Currently doesn't handle raw bytes, it assumes it's a string.
        - Could it be faster? Yes. But if you're printing to the term, that's the main bottleneck.

        future:
            - use [Rune] categories, or unicode regex classes instead of hard coded ranges.
            - test it as a custom [RipGrep Preprocessor](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#preprocessor)

        References:
            - <https://en.wikipedia.org/wiki/C0_and_C1_control_codes>

        Official charts:
            - 2400–243F = [Control Pictures](https://www.unicode.org/charts/PDF/U2400.pdf)
            - 0000-007f = [C0 Controls and Basic Latin.pdf](https://www.unicode.org/charts/PDF/U0000.pdf)
            - 007f-0080  = [C1 Controls and Latin-1 Suppliment.pdf](https://www.unicode.org/charts/PDF/U0080.pdf)

    .example
        PS> "`u{00}" | Format-ControlCharSymbol
        # output: ␀
    #>
    param(
        <#
        format unicode strings, making them safe.
            Null is allowed for the user's conveinence.
            allowing null makes it easier for the user to pipe, like:
            'gc' without -raw or '-split' on newlines
        #>
        [Alias('Text')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$InputText,

        # Preserves whitespace: tab, cr, tab.
        # useful when piping from something like ansi-highlighted Markdown files
        [Alias('AllowWhitespace')]
        [Parameter()][switch]$PreserveWhitespace,

        # Preserve \r\n, otherwise replace all other whitespace
        [Alias('AllowNewline')]
        [Parameter()][switch]$PreserveNewline,

        # extra options
        [Parameter()][hashtable]$Options

    )
    begin {
        # [hashtable]$ColorType = Join-Hashtable $ColorType ($Options.ColorType ?? @{})
        [hashtable]$Config = @{
            # AlignKeyValuePairs = $true
            # Title              = 'Default'
            # DisplayTypeName    = $true
        }


        # these are inclusive ranges, ie: [x, y]
        $Filters = @{

            'ControlChars_C0' = @{
                type = 'range'
                min  = 0x0
                max  = 0x1f
            }
            'Whitespace'      = @{
                type   = 'list'
                values = @(
                    0x20 # space
                    0xd  # cr
                    0x9  # tab
                    0xa  # newline
                )
            }
            'Newlines'        = @{
                type   = 'list'
                values = @(
                    0xd  # cr
                    0xa  # newline
                )
            }
        }
        $controlMin = $Filters.'ControlChars_C0'.min
        $controlMax = $Filters.'ControlChars_C0'.max + 1 # Because space isn't in C0
        $NullStr = "`u{2400}"
        [Text.StringBuider]$bufferSB = [string]::Empty

        $Config = Join-Hashtable $Config ($Options ?? @{})
    }

    process {
        $InputText | ForEach-Object {
            $CurrentLine = $_
            if ($Null -eq $CurrentLine) {
                $CurrentLine = "`u{0}"
                # return # [void]$bufferSB.Append( $nullStr )
            }
            $CurrentLine.EnumerateRunes() | ForEach-Object {
                $RuneInfo = $_ # is a [Text.Rune]
                $Codepoint = $RuneInfo.Value
                if ($Codepoint -ge $controlMin -and $Codepoint -le $controlMax ) {
                    if ($PreserveNewline) {
                        # todo: support '\r?\n' pairs
                        if ($Codepoint -in $Filters.Newlines.values ) {
                            [void]$bufferSB.Append( [char]::ConvertFromUtf32( $Codepoint ) )
                            return
                        }
                    }
                    if ($PreserveWhitespace) {
                        if ($Codepoint -in $Filters.Whitespace.values ) {
                            [void]$bufferSB.Append( [char]::ConvertFromUtf32( $Codepoint ) )
                            return
                        }
                    }
                    $Codepoint += 0x2400
                }
                [void]$bufferSB.Append( [char]::ConvertFromUtf32( $Codepoint ) )
            }
        }
    }
    end {
        # $bufferSB.ToString() | Join-String # no?
        $bufferSB.ToString()
    }
}
