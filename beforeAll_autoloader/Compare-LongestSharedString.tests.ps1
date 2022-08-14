BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'Compare-LongestSharedString' {

    It '"<A>" with "<B>" matches anything"' -ForEach @(
        @{
            A = 'abcd' ; Expected = $true
            B = 'abcde'
        }
        @{
            A = 'abcd' ; Expected = $true
            B = 'abcd'
        }
        @{
            A = 'bcd' ; Expected = $false
            B = 'abcd'
        }
    ) {
        Compare-LongestSharedPrefix -A $A -B $B
        | Should -Not -BeExactly [string]::Empty

    }
    Context 'Without PassThru' {
        Describe 'Using Codepoint Length Type' {
            It '"<A>" with "<B>" is <Expected>"' -Foreach @() {
                Set-ItResult -Pending -Because 'unicode comparison not written yet'
            }
        }
        Describe 'Using Char Length Type' {
            It '"<A>" with "<B>" is <Expected>"' -Foreach @(
                @{
                    A        = 'abcd'
                    B        = 'abcde'
                    Expected = 'abcd'
                }
                @{
                    A        = 'abcde'
                    B        = 'abcd'
                    Expected = 'abcd'
                }
                @{
                    A        = 'abcd'
                    B        = 'bcd'
                    Expected = ''
                }
                @{
                    A        = 'bcd'
                    B        = 'abcd'
                    Expected = ''
                }
            ) {
                Compare-LongestSharedPrefix -A $A -B $B
                | Should -BeExactly $Expected

            }
        }
    }
}