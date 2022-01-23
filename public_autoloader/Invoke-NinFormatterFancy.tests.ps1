#requires -modules @{ModuleName='Pester';ModuleVersion='5.0.0'}


Describe Invoke-NinFormatterFancy {
    BeforeAll {
        Import-Module Ninmonkey.Console -Force
        # . $(Get-ChildItem -Path $PSScriptRoot/.. -Recurse -Filter "$__PesterFunctionName.ps1")
        # $Mocks = Resolve-Path "$PSScriptRoot/Mocks"
        $ErrorActionPreference = 'Stop'
        $Sample = 'ls . | ? $True | %{ $_ * 3 }'
        $Expected = 'Get-ChildItem . | Where-Object $True | ForEach-Object { $_ * 3 }'
    }
    Describe 'FromPipeOrParam' {
        It 'FromPipe' {
            $Sample | Invoke-NinFormatterFancy | Should -Be $expected
        }
        It 'FromParam' {
            Invoke-NinFormatterFancy -ScriptDefinition $Sample | Should -Be $Expected
        }
    }
    It 'From Clipboard' {
        $sample | Set-Clipboard
        Invoke-NinFormatterFancy -FromClipboard | Should -Be $expected
    }
    It 'From History' -Skip {
        # Maybe testing history isn't easy
        $sample;
        Invoke-NinFormatterFancy -FromLastCommand | Should -Be $expected
    }

}
