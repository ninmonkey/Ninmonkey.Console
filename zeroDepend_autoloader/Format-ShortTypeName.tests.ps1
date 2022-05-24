BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'Format-ShortTypeName' {

    Context 'NoColor' {
        It 'Nested Env Info, wrapped in an array' {
            , @(Get-Item env:)
            | Format-ShortSciTypeName -NoColor
            | Should -BeExactly '[object[]]' -Because 'Top Level is object[]'
        }

        It 'Env Info provider Dict' {
            Format-ShortSciTypeName -NoColor -InputObject (Get-Item env:)
            | Should -BeExactly '[Dictionary<TKey, TValue>.ValueCollection]'
        }
    }
}
