
BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Test-IsDirectory" {
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