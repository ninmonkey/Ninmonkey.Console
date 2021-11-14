BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'Set-NinLocation' {
    It 'From $Profile' {
        Push-Location -StackName 'pest.nin'
        $Expected = (Get-Item $PROFILE).Directory.FullName
        $profile | Goto
        Get-Item . | ForEach-Object FullName | Should -Be $Expected
        Pop-Location -StackName 'pest.nin'        
    }
    It 'From [IO.FileSystemInfo]' {
        Push-Location -StackName 'pest.nin'
        $Somefile = Get-Item .. -file | Select-Object -First 1

        $somefile | Goto 

        Get-Location | ForEach-Object tostring 
        | Should -Be $Somefile.Directory
        
        Pop-Location -StackName 'pest.nin'        
    }
    # ($PROFILE | Split-Path -Parent) | Should -be (gi . | % fullname)

}