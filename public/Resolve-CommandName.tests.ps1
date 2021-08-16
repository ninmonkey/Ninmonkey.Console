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
    # 1] can't get boolean to display false
    Describe 'TryC: excepts none' {
        It '"<Name>" IncludeExe:<IncludeExe> Returns [<ExpectedType>]' -ForEach @(
            @{
                Name         = 'ls.exe'
                IncludeExe   = $True
                ExpectedType = [Management.Automation.ApplicationInfo]
            }
            @{
                Name         = 'ls.exe'
                ExpectedType = $null
            }
        ) {
            $splatParam = @{
                Name       = $Name
                IncludeExe = $IncludeExe ?? $false
            }
            # $IncludeExeLabel = [string]$IncludeExe # I tried this
            $result = . $__PesterFunctionName @splatParam

            if ($null -eq $ExpectedType) {
                $result.count | Should -Be 0
            }
            else {
                $result | Select-Object -First 1 | Should -BeOfType $ExpectedType
            }
        }
    }

    Describe 'IncludeExe' {
        # todo: future: do I mock a [fileinfo] return if not existing?
        It 'Return includes .exe' {
            (Resolve-CommandName 'ls' -IncludeExe ).Name -contains 'ls.exe'
            | Should -Be $True -Because 'ls.exe is returned by Get-ChildItem'

            (Resolve-CommandName 'ls.exe' -IncludeExe ).Name -contains 'ls.exe'
            | Should -Be $True -Because 'ls.exe is returned by Get-ChildItem'
        }
        It 'Return Excludes .exe' {
            (Resolve-CommandName 'ls' -IncludeExe:$False ).Name -contains 'ls.exe'
            | Should -Be $false -Because 'IncludeExe is off'

            (Resolve-CommandName 'ls.exe' -IncludeExe:$False ).Name -contains 'ls.exe'
            | Should -Be $false -Because 'IncludeExe is off'
        }
    }
    Describe 'OneOrNone' {
        # terrible names here
        # future: maybe the whole 'ConvertFrom' block should enumerate with and without strict?
        It 'On and Non-distinct .exe exists' {
            # tag: windows only / need a mock?
            { Resolve-CommandName 'ls' -IncludeExe -OneOrNone -ea stop }
            | Should -Throw -Because 'Ls.exe is installed'
        }
        It 'Off and Non-distinct .exe exists' {
            # tag: windows only / need a mock?
            { Resolve-CommandName 'ls' -IncludeExe -ea stop }
            | Should -Not -Throw -Because 'OneOrNone -eq $False'
        }
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
            @{ Name = (Get-Alias 'ls') ; Expected = 'Get-ChildItem' }
        ) {
            Resolve-CommandName $Name | Should -Be $Expected
        }
    }
    Describe 'Block In Question' {
        Describe 'Return Type' {
            It '"<Name>" Returns "<expected>"' -ForEach @(
                @{ Name = 'ls' ; Expected = [System.Management.Automation.CmdletInfo] }
                @{ Name = 'h1' ; Expected = [System.Management.Automation.FunctionInfo] }
            ) {
                . $__PesterFunctionName $Name | Should -BeOfType $Expected
            }
        }
        Describe 'TryA: Hardcoded - Return Type IncludeExe' {
            It '"<Name>" Returns "<expected>"' -ForEach @(
                @{
                    Name = 'ls.exe' ; IncludeExe = $True
                    Expected = [Management.Automation.ApplicationInfo]
                }

                @{
                    Name = 'ls.exe' ; Expected = $null
                }
            ) {
                . $__PesterFunctionName $Name -IncludeExe | Should -BeOfType $Expected
            }
        }
        Describe 'TryB: Dynamic - Return Type IncludeExe' {
            It '"<Name>" IncludeExe:<IncludeExe> Returns "<expected>"' -ForEach @(
                @{
                    Name       = 'ls.exe'
                    IncludeExe = $True
                    Expected   = [Management.Automation.ApplicationInfo]
                }
                @{
                    Name = 'ls.exe' ; Expected = $null
                }
            ) {
                # $Includes = $IncludeExe ?? $false
                $splatParam = @{
                    Name       = $Name
                    IncludeExe = $IncludeExe ?? $false
                }
                $result = . $__PesterFunctionName @splatParam
                $null -eq $result | Should -Be $True
            }
        }
    }
}
