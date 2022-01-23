#Requires -Version 7
#requires -modules @{ModuleName='Pester';ModuleVersion='5.0.0'}
BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe '_enumerateMyCommand' -Skip -Tag slow {
    # Commmand name itself doesn't exist anymore

    # It 'Runs without error' {
    #     # . _enumerateMyCommand Args
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
