
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
