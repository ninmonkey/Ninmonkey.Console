BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "ConvertTo-HexString" -Tag 'ConvertTo' {
    It 'Numeric literal' {
        0x10 | Hex | Should -Be '0x10'
        16 | Hex | Should -Be '0x10'
    }
}
