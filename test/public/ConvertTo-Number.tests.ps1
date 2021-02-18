BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "ConvertTo-Number" -Tag 'ConvertTo' {

    It 'Numeric Literal' {
        0x10 | ConvertTo-Number | Should -Be 0x10
        0x10 | ConvertTo-Number | Should -BeOfType [int]
        0x10 | ConvertTo-Number | Should -Not -BeOfType 'string' # redundant?
    }
    It 'Enum Value' {
        $expected = [int]([System.ConsoleColor]::DarkMagenta)
        [System.ConsoleColor]::DarkMagenta | ConvertTo-Number | Should -Be $expected
        [System.ConsoleColor]::DarkMagenta | ConvertTo-Number | Should -BeOfType [int]
    }
    It 'Hex String' {
        '0xff' | ConvertTo-Number | Should -Be 255
        '0xff' | ConvertTo-Number | Should -BeOfType [int]
    }
}
