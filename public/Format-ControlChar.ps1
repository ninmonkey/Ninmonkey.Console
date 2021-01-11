using namespace System.Text


function Format-ControlChar {
    <#
    .synopsis
        Converts unsafe control chars to their symbols (which are safe to print and pipe)
    .description
        Replaces C0-control codes with their unicode-symbol replacents at u+2400+
    .example
        PS> "`u{00}" | Format-ControlCharSymbol
        # output: ␀
    #>
    param(
        # Input text to map
        # allowing null makes it easier for the user to pipe, like 'gc' without -raw
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$InputObject

    )
    begin {
        $controlMin = 0x0
        $controlMax = 0x1f
        $bufferSB = [StringBuilder]::new()
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
                [void]$bufferSB.Append( [char]::ConvertFromUtf32( $Codepoint ) )
            }
        }
    }
    end {
        $bufferSB.ToString()
    }
}