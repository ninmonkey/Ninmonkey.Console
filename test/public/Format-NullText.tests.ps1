BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}
Describe "Format-NullText" -tags 'ConsoleOutput' {
    # Context 'Validate Piping' {
    BeforeAll {
        $Uni = @{
            Null       = "`u{0}"
            NullSymbol = '␀'
        }
    }
    It 'Actual Null' {
        $null | Format-NullText | Should -Be $Uni.NullSymbol
    }
    It 'Actual Null: As list' {
        , $null | Format-NullText | Should -Be $Uni.NullSymbol
    }
    It 'Null String' {
        $Uni.Null | Format-NullText | Should -Be $Uni.NullSymbol
    }
    It 'Return Int' {
        10 | Format-NullText | Should -be 10
    }
    It 'Pipe mixed types' {
        $Expected = 10, '', " ", $Uni.NullSymbol, $Uni.NullSymbol
        $Values = 10, '', " ", $null, $Uni.Null
        $Values | Format-NullText | Should -be $Expected
    }
}
