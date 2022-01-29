#Requires -Version 7.0

BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'Test-IsDirectory' {
    Context 'Pansies' {
        It 'IsContainer Strict' {
            Get-Item fg:\ | Ninmonkey.Console\Test-IsDirectory -IsContainer $False | Should -Be $false
        }
        It 'IsContainer loose' {
            Get-Item fg:\ | Ninmonkey.Console\Test-IsDirectory -IsContainer $true | Should -Be $true
        }
    }
    It 'Regular filesystem' {
        Get-Item . | Test-IsDirectory | Should -Be $True
        # todo : '
    }
    It 'Using Pansi''s Providor' {
        Get-Item fg:\ | Test-IsDirectory | Should -Be $True
    }

    It 'Dot Path' {
        Test-IsDirectory '.' | Should -Be $True
        '.' | Test-IsDirectory | Should -Be $True
    }
    It 'Path as [IO.FileSystemInfo]' {
        $fileObj = Get-ChildItem . -File | Select-Object -First 1

        Test-IsDirectory $fileObj
        | Should -Be $False

        $fileObj | Test-IsDirectory
        | Should -Be $False
    }

    It 'Pipe mixture' {
        $fileObj = Get-ChildItem . -File | Select-Object -First 1
        ($fileObj, '.', 'c:\') | Test-IsDirectory
        | Should -Be ($False, $True, $True)
    }
}
