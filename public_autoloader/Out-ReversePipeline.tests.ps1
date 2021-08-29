#requires -modules @{ModuleName='Pester';ModuleVersion='5.0.0'}
$SCRIPT:__PesterFunctionName = $myinvocation.MyCommand.Name.split('.')[0]

Describe "$__PesterFunctionName" -Tag Unit {
    BeforeAll {
        . $(Get-ChildItem -Path $PSScriptRoot/.. -Recurse -Filter "$__PesterFunctionName.ps1")
        # $Mocks = Resolve-Path "$PSScriptRoot/Mocks"
        $ErrorActionPreference = 'Stop'
    }
    It 'Runs without error' {
        $Null | . $__PesterFunctionName
        . $__PesterFunctionName
    }
    Describe 'Sequential numbers' {
        It 'Integers' {
            $Sample = 3, 1, 9
            $Expected = 9, 1, 3
            $Sample | Out-RevesrsePipeline
            | Should -Be $Expected -Because 'Manually wrote out the order' # might need array operator or enumeration
        }
    }
    Describe 'Mixed Object Types' {
        It 'Nested Array' {
            $Sample = 4, 'a', (, 30, 40), '🐈🐒', (Get-Item . | Select-Object -First 1), 'cat'
            $Sample = 4, 'a', (, 5, 6, 7), '🐈🐒', 'cat'
            $Expected = 'cat', '🐈🐒', (, 5, 6, 7), 'a', 4
            $Sample | Out-ReverseObjectPipeline
            | Should -Be $Expected -Because 'Manually wrote out the order' # might need array operator or enumeration
        }
    }
}
