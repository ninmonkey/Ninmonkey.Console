<#
    ref: https://jakubjares.com/2020/04/11/pester5-importing-ps-files/

     Tags like
        It "acceptance test 3" -Tag "WindowsOnly" {
            1 | Should -Be 1
        }

        It "acceptance test 4" -Tag "Slow", "LinuxOnly" {
            1 | Should -Be 1
        }

#>

BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
    $ErrorActionPreference = 'break'
    $ErrorActionPreference = 'Continue'
}

Describe 'Format-ControlChar' {
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
    Describe 'AllowWhitespace' {
        BeforeAll {

            $SampleMd = @"
# header

text
`ttabbed

- list
    - depth
    - bar
- item2
"@

        }
        It 'Disabled' {
            # 1 / 0
            $sample = "n`n t`t `nr`r"
            $expected = 'n␊ t␉ ␊r␍'
            1 / 0

            $sample | Format-ControlChar | Should -Be $expected
        }
        It 'Enabled' {
            $sample = "n`n t`t `nr`r"
            $expected = $sample
            $sample | Format-ControlChar -AllowWhitespace | Should -Be $sample -Because 'If whitespace is ignored, the string should be equivalent'
        }
        It 'Markdown | disabled' {
            $Expected = '# header␍␊␍␊text␍␊␉tabbed␍␊␍␊- list␍␊    - depth␍␊    - bar␍␊- item2'
            $SampleMd | Format-ControlChar | Should -Be $Expected -Because 'Manually tested output'
        }
    }
}
