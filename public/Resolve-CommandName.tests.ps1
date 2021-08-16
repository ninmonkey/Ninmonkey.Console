#requires -modules @{ModuleName='Pester';RequiredVersion='5.1.1'}
$SCRIPT:__PesterFunctionName = $myinvocation.MyCommand.Name.split('.')[0]

Describe "$__PesterFunctionName" -Tag Unit {
    BeforeAll {
        . $(Get-ChildItem -Path $PSScriptRoot/.. -Recurse -Filter "$__PesterFunctionName.ps1")
        # $Mocks = Resolve-Path "$PSScriptRoot/Mocks"
        $ErrorActionPreference = 'Stop'
    }
    It 'Runs without error' {
        . $__PesterFunctionName '*'
    }
    Describe 'ConvertFrom' {
        It 'Alias as String' {
            Resolve-CommandName 'ls' | Should -Be 'Get-ChildItem'
            Resolve-CommandName 'h1' | Should -Be 'Write-ConsoleHeader'
        }
        It 'Command as String' {
            Resolve-CommandName 'Get-ChildItem' | Should -Be 'Get-ChildItem'
            Resolve-CommandName 'Write-ConsoleHeader' | Should -Be 'Write-ConsoleHeader'
        }
        It 'Command as Command' {
            Get-Command 'ls' | Resolve-CommandName | Should -Be 'Get-ChildItem'
            Get-Command 'h1' | Resolve-CommandName | Should -Be 'Write-ConsoleHeader'
        }
        It '"<Name>" Returns "<expected>"' -ForEach @(
            @{ Name = 'ls' ; Expected = 'Get-ChildItem' }
            @{ Name = 'h1' ; Expected = 'Write-ConsoleHeader' }
            @{ Name = (Get-Command 'h1') ; Expected = 'Write-ConsoleHeader' }
        ) {
            Resolve-CommandName $Name | Should -Be $Expected
        }
    }
}
