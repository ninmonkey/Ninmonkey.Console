using namespace System.Text

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
        $controlMin = 0x0
        $controlMax = 0x1f
        $finalString = ""
        # future: use a string builder

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