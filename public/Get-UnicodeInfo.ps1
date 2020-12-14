function Get-UnicodeInfo {
    <#
    .description
        Converts strings to codepoints, and display byte strings  using common encodings
    .notes
        'todo: add colors to default format-list'

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$Text
    )

    begin {
        Write-Warning 'todo: other props like codepoint and categories'
    }
    Process {
        $text.EnumerateRunes() | ForEach-Object {
            $Codepont = $_.Value
            $Rune = [char]::ConvertFromUtf32( $Codepont )

            Write-Verbose "Item: $Rune"
            $info = [ordered]@{
                Hex         = $Codepont.ToString('x').ToLower()
                Dec         = $Codepont
                Utf8        = ([System.Text.Encoding]::UTF8.GetBytes( $Rune ) | Format-Hex | Select-Object -exp HexBytes).tolower()
                Utf16LE     = ([System.Text.Encoding]::Unicode.GetBytes( $Rune ) | Format-Hex | Select-Object -exp HexBytes).tolower()
                Utf16BE     = ([System.Text.Encoding]::BigEndianUnicode.GetBytes( $Rune ) | Format-Hex | Select-Object -exp HexBytes).tolower()
                Utf8Length  = $_.Utf8SequenceLength
                Utf16Length = $_.Utf16SequenceLength
                Rune        = $Rune
            }
            return [pscustomobject]$info
        }
    }
}
