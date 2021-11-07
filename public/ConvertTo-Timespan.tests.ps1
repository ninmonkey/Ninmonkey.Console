#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.0' }
#Requires -Version 7

BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'ConvertTo-Timespan' {
    it 'first' {
        $tslist = @(
            2 | days
            3 | hours
        )

        $ts_sum = $tslist | Measure-Object TotalMilliSeconds -Sum | % Sum | %{ 
        [timespan]::new(0,0,0,0,$_)
        } 

        $ts_sum | Should -be (RelativeTs 2d3h -debug)

        $tslist = @(
            2 | days
            3 | hours
        )

        $total_ms = $tslist | Measure-Object TotalMilliSeconds -Sum | % Sum

        $ts_sum = $total_ms  | %{ 
          [timespan]::new(0,0,0,0,$_)
        } 

    }
}