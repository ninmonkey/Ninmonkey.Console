BeforeAll {
    Import-Module Ninmonkey.console -Force
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

}

Describe 'Write-ConsoleText' -Tag 'ConvertTo' {
    It 'something' {
        $true | Should -Be $true
    }
    It 'Text -Foreground as Hex Color #feaabb' {
        Write-ConsoleText 'foo' -fg '#feaabb'
        | ForEach-Object tostring
        | Should -Be '[38;2;254;170;187mfoo[39m' -Because 'Ansi Escaped FG Color #feaabb'
    }
    It 'Text -Foreground as Named Color "blue"' {
        $Expected = '[38;2;0;0;255mfoo[39m'
        Write-ConsoleText 'foo' -fg 'blue'
        | ForEach-Object tostring
        | Should -Be $Expected -Because 'Ansi Escaped FG Color "blue"'
    }

    #     It 'Joining Basic Text' {
    #         $expected = '
    # [38;2;254;170;187mfoo[39m
    # [38;2;0;0;255mcat[39m
    # '
    #         @(
    #             Write-ConsoleText 'foo' -fg '#feaabb'
    #             Write-consoleText 'cat' -fg 'blue'
    #         ) | ForEach-Object tostring
    #         | Should -Be $expected -Because 'AnsiEscape merged by defaults'
    #     }
}
