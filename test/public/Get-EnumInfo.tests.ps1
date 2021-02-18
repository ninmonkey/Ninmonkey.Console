BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-EnumInfo" -Tag 'ConvertTo' {
    It 'Test against [int] casting' {
        $expected = [int]([System.ConsoleColor]::DarkMagenta)
        [System.ConsoleColor] | Get-EnumInfo | Where-Object Name -EQ 'DarkMagenta' | ForEach-Object Value
        | Should -Be $expected
    }
}