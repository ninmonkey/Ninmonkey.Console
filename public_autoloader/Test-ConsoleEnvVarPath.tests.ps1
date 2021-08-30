#requires -modules @{ModuleName='Pester';ModuleVersion='5.0.0'}
$SCRIPT:__PesterFunctionName = $myinvocation.MyCommand.Name.split('.')[0]

Describe "$__PesterFunctionName" -Tag Unit {
    BeforeAll {
        Import-Module Ninmonkey.Console -Force
        # . $(Get-ChildItem -Path $PSScriptRoot/.. -Recurse -Filter "$__PesterFunctionName.ps1")
        # $Mocks = Resolve-Path "$PSScriptRoot/Mocks"
        $ErrorActionPreference = 'Stop'
    }
    It 'Runs without error' {
        $__PesterFunctionName
        . $__PesterFunctionName 'Path' 'foo'
        return
    }
    Describe 'ExpectedDefaults' {
        It 'Windows Paths' -Tag 'Windows' {
            Test-ConsoleEnvVarPath -Name 'Path' -Path 'C:\WINDOWS\system32'
            | Should -Be $True

            Test-ConsoleEnvVarPath -Name 'Path' -Path 'C:\WINDOWS\System31'
            | Should -Be $False
        }
    }
}
