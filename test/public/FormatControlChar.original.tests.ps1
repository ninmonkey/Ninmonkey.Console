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
    # 1] either run adjacent file  (foo.tests.ps1 -> foo.ps1)
    #. $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    # 2] or if you're using multiple commands
    Import-Module Dev.Nin -Force # Is this the correct way to import
    $ErrorActionPreference = 'stop'
    $NullStr = '␀' # "`u{2400}"
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


    It '"<Label>" Returns "<expected>"' -ForEach @(
        @{ Label = 'Red'; AnsiString = "`e[91mhi world`e[39m!"; Expected = '␛[91mhi world␛[39m!' }
    ) {
        $AnsiString | Format-ControlChar | Should -Be $Expected -Because 'Manually Written Samples'
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
            It '"<Sample>" Returns "<expected>"' -ForEach @(
                @{ sample = "n`n t`t `nr`r" ; expected = 'n␊ t␉ ␊r␍' }
            ) {
                . $__PesterFunctionName $Sample | Should -Be $Expected
            }

        }
        if ($false) {
            It 'Disabled' -Skip {
                # 1 / 0


                $sample | Format-ControlChar | Should -Be $expected
            }
            It 'Enabled' {
                $sample = "n`n t`t `nr`r"
                $expected = $sample
                $sample | Format-ControlChar -AllowWhitespace | Should -Be $sample -Because 'If whitespace is ignored, the string should be equivalent'
            }
        }

        It 'Markdown | disabled' {
            $Expected = '# header␍␊␍␊text␍␊␉tabbed␍␊␍␊- list␍␊    - depth␍␊    - bar␍␊- item2'
            $SampleMd | Format-ControlChar | Should -Be $Expected -Because 'Manually tested output'
        }
    }
}
