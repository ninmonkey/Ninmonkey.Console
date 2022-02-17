# # requires -modules @{ModuleName='Pester';ModuleVersion='5.0.0'}
# # $SCRIPT:__PesterFunctionName = $myinvocation.MyCommand.Name.split('.')[0]

Describe 'Measure-NinChildItem' -Tag Unit {
    BeforeAll {
        Import-Module Ninmonkey.Console -Force
        # . $(Get-ChildItem -Path $PSScriptRoot/.. -Recurse -Filter "$__PesterFunctionName.ps1")
        # $Mocks = Resolve-Path "$PSScriptRoot/Mocks"
        # $ErrorActionPreference = 'break'
    }
    It 'Runs without error' -Skip -Tag 'SlowIO' {
        { Measure-NinChildItem -InputPath '.' }
        | Should -Not -Throw
    }
    Describe 'Bytes Match Get-ChildItem' {
        # It '"<Directory>" Returns "<bytes>"' -ForEach @(
        It '"<Directory>" Returns Matching Bytes"' -ForEach @(
            @{ Directory = 'C:\nin_temp' }
        ) {
            $query_func = . $__PesterFunctionName -Path $Directory
            $query_gci = Get-ChildItem -Path $Directory -Force -Recurse
            | Measure-Object Length -Sum | ForEach-Object Sum
            $query_func.bytes
            | Should -Be $query_gci -Because 'They should return exactly the same bytes'

        }

    }
}
