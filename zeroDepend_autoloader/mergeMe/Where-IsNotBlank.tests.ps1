BeforeAll {
    Import-Module Dev.Nin -Force
}

Describe 'Where-IsNotBlank' {
    BeforeAll {

    }
    Describe 'Exceptions' {
        It 'Literal Empty' {
            { '' | Test-IsNotBlank } | Should -Not -Throw
            { Test-IsNotBlank '' } | Should -Not -Throw

        }
        It 'Literal Empty' {
            Test-IsNotBlank '' | Should -Be $False
        }
    }
    It 'Basic' {
        Test-IsNotBlank ' ' | Should -Be $True
    }
}