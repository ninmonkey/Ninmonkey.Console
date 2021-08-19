#requires -modules @{ModuleName='Pester';RequiredVersion='5.1.1'}
$SCRIPT:__PesterFunctionName = $myinvocation.MyCommand.Name.split('.')[0]

Describe "$__PesterFunctionName" {
    BeforeAll {
        . $(Get-ChildItem -Path $PSScriptRoot/.. -Recurse -Filter "$__PesterFunctionName.ps1")
        # $Mocks = Resolve-Path "$PSScriptRoot/Mocks"
        $ErrorActionPreference = 'Stop'
        # ensure ls.exe exists, or mock it.

    }
    It 'Runs without error' {
        . $__PesterFunctionName '*'
    }

    # 1] I'm having trouble getting the '<IncludeExe>' to display true/false
    # 2] What's the right way to mock a 'ls.exe' file so that 'Get-Command' will find it.?
    Describe '-IncludeExe Return Type' {
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

    Describe '(hardcoded) -IncludeExe contains a "ls.exe"' {
        # todo: future: do I mock a [fileinfo] return if not existing?
        It 'When On' {
            (Resolve-CommandName 'ls' -IncludeExe ).Name -contains 'ls.exe'
            | Should -Be $True -Because 'ls.exe is returned by Get-ChildItem'

            (Resolve-CommandName 'ls.exe' -IncludeExe ).Name -contains 'ls.exe'
            | Should -Be $True -Because 'ls.exe is returned by Get-ChildItem'
        }
        It 'When Off' {
            (Resolve-CommandName 'ls' -IncludeExe:$False ).Name -contains 'ls.exe'
            | Should -Be $false -Because 'IncludeExe is off'

            (Resolve-CommandName 'ls.exe' -IncludeExe:$False ).Name -contains 'ls.exe'
            | Should -Be $false -Because 'IncludeExe is off'
        }
    }
    Describe '-OneOrNone will Throw' {
        # terrible names here
        # future: maybe the whole 'ConvertFrom' block should enumerate with and without strict?
        It 'On and Non-distinct "ls" exists' {
            # tag: windows only / need a mock?
            { Resolve-CommandName 'ls' -IncludeExe -OneOrNone -ea stop }
            | Should -Throw -Because 'Ls.exe is installed'
        }
        It 'Off and Non-distinct "ls" exists' {
            # tag: windows only / need a mock?
            { Resolve-CommandName 'ls' -IncludeExe -ea stop }
            | Should -Not -Throw -Because 'OneOrNone -eq $False'
        }
        It 'Throwing When $Null?' -ForEach @(
            @{
                ErrorAction = 'Ignore'
                Name        = 'adsfaeifjejaifjfaiwoefnnagoinagdsgva'
                ExpectThrow = $false
                # This because are from thinking about scale
                # When tests are longer, the inner [SB] asserts are further away from the
                # conditions,
                Because     = 'Because "Get-Command" returns null when -Ea Ignore'
            }
            @{
                ErrorAction = 'Stop'
                Name        = 'adsfaeifjejaifjfaiwoefnnagoinagdsgva'
                ExpectThrow = $true
                Because     = 'Because "Get-Command" throws when nothing is found'
            }
        ) {

            if ($ExpectThrow) {
                { Resolve-CommandName -CommandName $Name -Ea:$ErrorAction }
                | Should -Throw -Because $Because
            }
            else {
                { Resolve-CommandName -CommandName $Name -Ea:$ErrorAction }
                | Should -Not -Throw -Because $Because
            }
        }
    }

    Describe 'Section In Question' {
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
                    # error:
                    #       [-] "ls.exe" Returns "" 62ms (61ms|1ms)
                    #       RuntimeException: The right operand of '-is' must be a type.
                }
            ) {
                . $__PesterFunctionName $Name -IncludeExe | Should -BeOfType $Expected
            }
        }
        Describe 'TryB: Dynamic - Return Type IncludeExe' {
            It '"<Name>" IncludeExe:<IncludeExe> Returns "<expected>"' -ForEach @(
                @{
                    # error:
                    # [-] "ls.exe" IncludeExe:True Returns "System.Management.Automation.ApplicationInfo"
                    #  Expected $true, but got $false.
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
