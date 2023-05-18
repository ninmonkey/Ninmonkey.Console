BeforeAll {
    Import-Module Ninmonkey.Console -Force -PassThru
}

Describe 'Format-UnicodeCodepoints' {
    Context 'Does not throw' {
        Context 'As Pipeline' {
            it 'Pipe: Text' {
                { 'asdf' | Format-UnicodeCodepoints }
                | Should -not -Throw
            }
            it 'Pipe: EmptyText' {
                { '' | Format-UnicodeCodepoints }
                | Should -not -Throw
            }
            it 'Pipe: Null' {
                { $null | Format-UnicodeCodepoints }
                | Should -not -Throw
            }
        }
        Context 'As Param' {
            it 'Pipe: Text' {
                { Format-UnicodeCodepoints -input 'asdf' }
                | Should -not -Throw
            }
            it 'Pipe: EmptyText' {
                { Format-UnicodeCodepoints -input '' }
                | Should -not -Throw
            }
            it 'Pipe: Null' {
                { Format-UnicodeCodepoints -input $Null }
                | Should -not -Throw
            }
        }
    }
    it 'Render <Sample> Should Be <Expected>' -ForEach @(
        @{
            Sample   = 'abcd'
            Expected = '61626364'
        }
        @{
            Sample   = '🐒🙊'
            Expected = '1f4121f64a'
        }
    ) {
        $Sample | Format-UnicodeCodepoints | Should -BeExactly $Expected
    }

}