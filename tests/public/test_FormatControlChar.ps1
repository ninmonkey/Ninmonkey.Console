
if ($false) {
    20..40 | ForEach-Object { [char]::ConvertFromUtf32( $_ ) | Join-String }  | Format-ControlChar -Debug -Verbose
    hr
    , (
        ("a`u{0}c`u{10}d"),
        ("a`u{0}c`u{10}d")
    ) | Format-ControlChar

    , @(345, $null, "adfs" ) | Format-ControlChar -Verbose -Debug
}

, (
    ("a`u{0}c`u{10}d"),
    ("a`u{0}c`u{10}d")
) | Format-ControlChar
| Should -be 'a␀c␐da␀c␐d'



h1 'final'
0..50 | ForEach-Object {
    [char]::ConvertFromUtf32( $_ )
} | ForEach-Object {
    $CurrentLine = $_
    $CurrentLine.enumerateRunes() | ForEach-Object {
        $RuneInfo = $_
        $Codepoint = $RuneInfo.Value
        if ($Codepoint -ge 0 -and $Codepoint -le 0x1f ) {
            $Codepoint += 0x2400
        }
        [char]::ConvertFromUtf32( $Codepoint )
    }

    # $_ -replace '[\x00-\x1f]', '~'
} | Join-String -sep ''