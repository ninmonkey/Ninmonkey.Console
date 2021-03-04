function Get-UnicodeInfo {
    <#
    .description
        Converts strings to codepoints, and display byte strings  using common encodings
    .notes
        **enumerate codepoints**, not **graphemes**
        'todo: add colors to default format-list'

    #>
    [Alias('Get-RuneInfo')]
    [CmdletBinding()]
    # -Basic could be a param that is faster, if operations are a bottlenetck

    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$Text
    )

    begin {
        # 'todo: [1] props like categories, blocks, ranges [2] PSTypeName Custom View'
        # UnicodeCategory Enum
    }
    Process {
        $text.EnumerateRunes() | ForEach-Object {
            $Codepont = $_.Value
            $Rune = [char]::ConvertFromUtf32( $Codepoint )

            Write-Verbose "Item: $Rune"
            $info = [ordered]@{
                PSTypeName  = 'Nin.RuneInfo'
                Hex         = $Codepont.ToString('x').ToLower() # to: conversion should ber in view
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


if ($DebugTestMode) {
    $strList = @(
        '🐒'
        '[System.Text.StringBuilder]::new()'
    )
    $strList | Get-RuneInfo
    | Format-Table *

    hr 1

    $strList | ForEach-Object {
        [System.Text.Encoding]::UTF8.WebName
        $byteStr = [System.Text.Encoding]::UTF8.GetBytes( $_ )

    }
    # } | Join-String -sep "`n" -FormatString '0x{0:x} = {0}' -prop { $_ }
}