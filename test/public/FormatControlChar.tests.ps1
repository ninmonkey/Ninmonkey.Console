
BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Format-ControlChar" {
    It 'Convert Null' {
        [char]::ConvertFromUtf32(0) | Format-ControlChar
        | Should -Be '␀'
    }
    It 'Test First 50 codepoints' {
        $sampleRunes = 0..50 | ForEach-Object {
            [char]::ConvertFromUtf32( $_ )
        }
        $expected = '␀␁␂␃␄␅␆␇␈␉␊␋␌␍␎␏␐␑␒␓␔␕␖␗␘␙␚␛␜␝␞␟ !"#$%&''()*+,-./012'

        $result = $sampleRunes | Format-ControlChar
        $result | Should -Be $Expected
    }
}