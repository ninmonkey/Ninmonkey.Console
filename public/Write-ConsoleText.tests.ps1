BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Write-ConsoleText' -Tag 'ConvertTo' {
    It 'something' {
        $true | Should -Be $true
    }
}
