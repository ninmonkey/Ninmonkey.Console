# #requires -modules @{ModuleName='Pester';ModuleVersion='5.0.0'}
# $SCRIPT:__PesterFunctionName = $myinvocation.MyCommand.Name.split('.')[0]

BeforeAll {
    Import-Module Ninmonkey.Console -Force
    $ErrorActionPreference = 'Stop'
    # $ErrorActionPreference = 'break'
    # ensure ls.exe exists, or mock it.
}

Describe 'Resolve-CommandName' {
    It 'Temp test to flag bug' {
        
        { Get-Command '?str' | resCmd -q } | Should -Not -Throw
        # output: 
        # gc: @splat:
        #   error the term jstr is not a command
    }
    Describe 'Resolve Source Name' {
        It '<Query> returns <Expected>' -ForEach @(
            @{ Query = 'ls'; Expected = 'Microsoft.PowerShell.Management\Get-ChildItem' }
            @{ Query = 'goto'; Expected = 'Ninmonkey.Console\Set-NinLocation' }
        ) {
            Resolve-CommandName -QualifiedName -CommandName $Query
            | Should -Be $Expected
        }

    }

    # It 'Runs without error' {
    #     Resolve-CommandName '*'
    # }
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
            $result = Resolve-CommandName @splatParam

            if ($null -eq $ExpectedType) {
                $result.count | Should -Be 0
            } else {
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
    Describe '-OneOrNone will Throw' -Skip {
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
            } else {
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
                Resolve-CommandName $Name | Should -BeOfType $Expected
            }
        }
        Describe 'TryA: Hardcoded - Return Type IncludeExe' {
            It '"<Name>" Returns "<expected>"' -ForEach @(
                @{
                    Name         = 'ls.exe'
                    IncludeExe   = $True
                    ExpectedType = [Management.Automation.ApplicationInfo]
                }

                @{
                    Name         = 'ls.exe'
                    IncludeExe   = = $false
                    ExpectedType = $null
                    # ExpectedType = $null
                    # error:
                    #       [-] "ls.exe" Returns "" 62ms (61ms|1ms)
                    #       RuntimeException: The right operand of '-is' must be a type.
                }
            ) {
                $splat = @{
                    Name     = $Name
                    Expected = $Expected
                }


                if ($ExpectedType) {
                    $query = Resolve-CommandName $Name -IncludeExe
                    $query | Should -BeOfType $ExpectedType
                }
                if ($IncludeExe) {
                    $splat.Add('IncludeExe', $IncludeExe)
                }
                Resolve-CommandName @splat
                # Resolve-CommandName $Name -IncludeExe:$IncludeExe | should -Be
                # Resolve-CommandName $Name -IncludeExe | Should -BeOfType $Expected
                # Resolve-CommandName $Name -IncludeExe | Should -BeOfType $Expected
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
                $result = Resolve-CommandName @splatParam
                $null -eq $result | Should -Be $True
            }
        }
    }
}
