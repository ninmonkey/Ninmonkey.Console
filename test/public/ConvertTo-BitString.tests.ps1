BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "ConvertTo-BitString" -Tag 'ConvertTo' {

    It 'First 4 bytes' {
        @(0..3  | Bits) -join ', ' | Should -Be '0000.0000, 0000.0001, 0000.0010, 0000.0011'
    }
}
