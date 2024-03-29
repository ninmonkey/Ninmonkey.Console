#Requires -Module @{ ModuleName = 'Pester'; ModuleVersion = '5.0' }
#Requires -Version 7

BeforeAll {
    Import-Module Ninmonkey.Console -Force
    Import-Module Dev.Nin -Force
}

Describe 'Get-TimeStuff' -Tag 'requiresDev.Nin' {
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

}
