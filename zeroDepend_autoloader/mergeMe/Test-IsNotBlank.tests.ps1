#Requires -modules @{ModuleName='Pester';ModuleVersion='5.0.0'}
#Requires -Version 7


BeforeAll {
    Import-Module Dev.Nin -Force
}

Describe 'Test-IsNotBlank' {
    BeforeAll {

    }
    Describe 'Exceptions' {
        It 'Literal Empty' {
            { '' | Test-IsNotBlank } | Should -Not -Throw
            { Test-IsNotBlank '' } | Should -Not -Throw

        }
        It 'Literal Empty2' {
            Test-IsNotBlank '' | Should -Be $False
        }
    }
    It 'Basic' {
        Test-IsNotBlank ' ' | Should -Be $false
    }
}
