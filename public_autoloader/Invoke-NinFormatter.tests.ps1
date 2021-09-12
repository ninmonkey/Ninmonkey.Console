#requires -modules @{ModuleName='Pester';ModuleVersion='5.0.0'}
$SCRIPT:__PesterFunctionName = $myinvocation.MyCommand.Name.split('.')[0]

Describe "$__PesterFunctionName" -Tag Unit {
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
            $Sample | Invoke-NinFormatter | Should -Be $expected
        }
        It 'FromParam' {
            Invoke-NinFormatter -ScriptDefinition $Sample | Should -Be $Expected
        }
    }
    It 'From Clipboard' {
        $sample | Set-Clipboard
        Invoke-NinFormatter -FromClipboard | Should -Be $expected
    }
    It 'From History' -Skip {
        # Maybe testing history isn't easy
        $sample;
        Invoke-NinFormatter -FromLastCommand | Should -Be $expected
    }

}
