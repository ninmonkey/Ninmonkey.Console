BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'Test-IsSubDirectory' {
    It '<Child> of <Parent> is <expected>' -ForEach @(
        @{
            Child    = "$env:userprofile"
            Parent   = 'c:\users'
            Expected = $true
        }
    ) {
        Test-IsSubDirectory $Child -Parent $Parent
        | Should -Be $Expected
    }
}
