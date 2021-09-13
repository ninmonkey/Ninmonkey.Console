#requires -modules @{ModuleName='Pester';ModuleVersion='5.0.0'}
$SCRIPT:__PesterFunctionName = $myinvocation.MyCommand.Name.split('.')[0]

Describe "$__PesterFunctionName" -Tag Unit {
    BeforeAll {
        Import-Module Ninmonkey.Console -Force
        # . $(Get-ChildItem -Path $PSScriptRoot/.. -Recurse -Filter "$__PesterFunctionName.ps1")
        # $Mocks = Resolve-Path "$PSScriptRoot/Mocks"
        $ErrorActionPreference = 'Stop'
        $ErrorActionPreference = 'break'
    }
    # It 'Runs without error' {
    #     # . $__PesterFunctionName Args
    # }

    Describe 'Using -Name' {
        It 'With -Category' {
            Get-NinCommandName -Name *join* -Category Regex🔍
            | Should -Contain 'Join-Regex'
        }
        It 'With -Category[]' {
            $query = Get-NinCommandName -Category Regex🔍, DevTool💻
            $query | Should -Contain 'Join-Regex'
            $query | Should -Contain 'DevTool💻-GetArgumentCompleter'

        }
    }
}
