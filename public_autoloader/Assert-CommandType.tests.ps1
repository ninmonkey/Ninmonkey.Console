BeforeAll {
    Import-Module Ninmonkey.Profile -Force
}

Describe 'Assert-CommandType' {
    It 'hardcoded' {
        Get-Command Microsoft.PowerShell.Core\Get-Command
        $false | Should -Be $True
    }

}