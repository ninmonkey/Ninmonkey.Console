BeforeAll {
    Import-Module Ninmoonkey.Console -Force
}


# $samplePath = Get-Item .\public_autoloader\Measure-NinChildItem.ps1
# ConvertTo-BreadCrumb $SamplePath
# ConvertTo-BreadCrumb $SamplePath.FullName

Describe 'ConvertTo-BreadCrumb' {
    It 'Detect DoubleBackslash' {
        'foo\\bar\\cat' | ConvertTo-BreadCrumb
        | Should -BeExactly @('foo', 'bar', 'cat')
    }
    It 'Detect Backslash' {
        'foo\bar\cat' | ConvertTo-BreadCrumb
        | Should -BeExactly @('foo', 'bar', 'cat')
    }
    It 'Detect Forward Slash' {
        'foo/bar/cat' | ConvertTo-BreadCrumb
        | Should -BeExactly @('foo', 'bar', 'cat')

    }
}
