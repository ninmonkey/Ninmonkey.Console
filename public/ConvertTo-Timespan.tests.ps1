#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.0' }
#Requires -Version 7

BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'ConvertTo-Timespan' {
    It 'first' {
        $tslist = @(
            2 | days
            3 | hours
        )

        $ts_sum = $tslist | Measure-Object TotalMilliSeconds -Sum | ForEach-Object Sum | ForEach-Object { 
            [timespan]::new(0, 0, 0, 0, $_)
        } 

        $ts_sum | Should -Be (RelativeTs 2d3h -Debug)

        $tslist = @(
            2 | days
            3 | hours
        )

        $total_ms = $tslist | Measure-Object TotalMilliSeconds -Sum | ForEach-Object Sum

        $ts_sum = $total_ms | ForEach-Object { 
            [timespan]::new(0, 0, 0, 0, $_)
        }     
    }
    Describe 'Partial Parameters' {
        It 'OnlyMs' {
            ConvertTo-Timespan '1m' | ForEach-Object TotalSeconds | Should -Be 60
        }
        It 'Single ms' {
            ConvertTo-Timespan '1ms' | ForEach-Object TotalMilliseconds
            | Should -Be 1 -Because '"ms" should parse to ms, not the partial match of "s"'
        }
        It 'Explicit 0s' {
            ConvertTo-Timespan '0s1ms' | ForEach-Object TotalMilliseconds | Should -Be 1            
        }

    }
}