using namespace System.Text

# h1 'final'
# 0..50 | ForEach-Object {
#     [char]::ConvertFromUtf32( $_ )
# } | ForEach-Object {
#     $CurrentLine = $_
#     $CurrentLine.enumerateRunes() | ForEach-Object {
#         $RuneInfo = $_
#         $Codepoint = $RuneInfo.Value
#         if ($Codepoint -ge 0 -and $Codepoint -le 0x1f ) {
#             $Codepoint += 0x2400
#         }
#         [char]::ConvertFromUtf32( $Codepoint )
#     }

#     # $_ -replace '[\x00-\x1f]', '~'
# } | Join-String -sep ''

function Format-ControlChar {
    <#
    .synopsis
        Converts unsafe control chars to their symbols, which are safe to print
    .description
        Replaces C0-control codes with their unicode-symbol replacents at u+2400+
    .example
        PS> "`u{00}" | Format-ControlCharSymbol
        # output: ␀
    .notes
        todo:
            - [  ] use string builder for `$finalString`
        better performance:
            - [ ] use string builder, or pipe results directly directly
    #>
    param(
        # Input text to map
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$InputObject

    )
    begin {
        $uni_range = 0..0x1f
        $uni_increment = 0x2400
        $controlMin = 0x0
        $controlMax = 0x1f
        $finalString = ""
        $runeReplace = [Rune]::ReplacementChar
        $runeNull = [char]::ConvertFromUtf32( 0 ) # or "`u{0}" [null]
        $runeNoSign = [char]::ConvertFromUtf32( 0x1f6ab )  # or "`u{1f6ab}" 🚫
    }

    process {
        $InputObject | ForEach-Object {
            $CurrentLine = $_
            $CurrentLine.EnumerateRunes() | ForEach-Object {
                $RuneInfo = $_ # is a [Text.Rune]
                $Codepoint = $RuneInfo.Value
                if ($Codepoint -ge $controlMin -and $Codepoint -le $controlMax ) {
                    $Codepoint += 0x2400
                }
                $finalString += [char]::ConvertFromUtf32( $Codepoint )
            }
        }
    }
    end {
        $finalString
    }
}