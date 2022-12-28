BeforeAll {
    Import-Module Ninmonkey.Console -Force *>$Null
}

Describe 'StrSplit-Lines' {
    It 'manualTest1' {
        (
            @(
                "a`r`n"
                'z', 'x'
            )
            | StrSplit-Lines
        ).count
        | Should -BeExactly 4 -Because 'static declared test'
    }
    It 'test2' {
        (
            0..4 -join "`r`n"
            | StrSplit-Lines
        ).count
        | Should -BeExactly 5 -Because 'hardcoded example'

    }
}
