BeforeAll {
    Import-Module Ninmonkey.Console -Force *>$null -SkipEditionCheck -DisableNameChecking
}

Describe 'New-RegexLiteralOr' {
    It 'Backslash Path' {
        $In  = 'C:\Users\Bob'
        $Ex = '((C:\\Users\\Bob))'
        $In | New-RegexLiteralOr | Should -BeExactly $Ex -Because 'Currently Single Items still parens'
    }
    It 'Path <In> as <Ex>' -ForEach @(
        @{ In = 'C:\Users\Bob' ; Ex = '((C:\\Users\\Bob))' }
        @{ In = '/foo/bar' ; Ex = '((/foo/bar))' }

        @{
            In = @(
                '/foo/bar',
                'C:\Users\Bob'
            )
            Ex = '((/foo/bar)|(C:\\Users\\Bob))'
        }
    ) {
        $In | New-RegexLiteralOr
        | Should -BeExactly $Ex -Because 'hardcoded test'
    }

}