using namespace System.Collections.Generic

BeforeAll {
    # . "$PSScriptRoot/Assert-HashtableEqual.ps1"
    Import-Module Ninmonkey.Console -Force
    $ErrorActionPreference = 'Break'
}


Describe 'Assert-HashtableEqual' {

    BeforeAll {
        # $false | Should -Be $True -Because 'NYI'
    }

    Describe 'CaseSensitivity' {
        Context 'Insensitive' {
            BeforeAll {
                $h1 = @{ 'species' = 'dog' ; 'lives' = 1 }
                $h2 = @{ 'lives' = 1; 'Species' = 'dog' }
                $h2_lower = @{ 'lives' = 1; 'species' = 'dog' }
                $h_extraKeys = $h1 + @{ 'Extra' = 'Something' }
            }
            It 'Basic' {
                Assert-HashtableEqual @{'a' = 3 } @{'A' = 9 }
                | Should -Be $true
            }

            It 'Equal Keys' {
                Assert-HashtableEqual $h1 $h2 | Should -Be $True
                Assert-HashtableEqual $h1 $h2_lower | Should -Be $True
            }
            It 'Extra Values' {
                Assert-HashtableEqual $h1 $h_extraKeys | Should -Be $False
            }
        }
        Context 'Sensitive' {

        }

    }
}