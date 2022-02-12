BeforeAll {
    # . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
    Import-Module Ninmonkey.Console -Force

}

Describe 'ConvertTo-Timespan' {
    # BeforeAll {
    #     $SampleData = @(
    #         '3d1m'
    #         '3d1a'
    #         '-3d1m'
    #         '-3d1a'
    #         '1d3s'
    #         '1d3-s'
    #         '1d3h4m1s'
    #         '3d'
    #     )
    # }
    BeforeAll {

    }
    Describe 'Empty Values' {
        It 'Zero is Valid' {
            { Ninmonkey.Console\ConvertTo-Timespan '0s' -ZeroIsValid -ea stop }
            | Should -Not -Throw
        }
        It 'Zero Should Throw' {
            { Ninmonkey.Console\ConvertTo-Timespan '0s' -ea stop }
            | Should -Throw
        }
    }
    <#
    once parsing is fixed:

        mixed decimal cases, before, after, empty, both
            31s
            3.s
            .3s
            .0s

            0.3d0.2h0.4m1.45s93.4ms
            0.3d-0.2h0.4m1.45s93.3ms

        all negatives

             -0.1d-0.1h-0.1m-0.1s-0.1ms

        regular enumeration
            1.1s
            0.1s
            0342.234s
            -1.1s
            -0.1s
            -0342.234s
            0.0s
            0s

            2d
    #>
    It 'Returns <expected> (<name>)' -ForEach @(
        # I think some values go out of range or precision errors
        @{ Name = '0s'; Expected = ([timespan]::new(0, 0, 0, 0, 0)) }
        @{ Name = '3d1m'; Expected = ([timespan]::new(3, 0, 1, 0, 0)) }
        @{ Name = '9d3h'; Expected = ([timespan]::new(9, 3, 0, 0, 0)) }
        @{ Name = '9d3h1d'; Expected = ([timespan]::new(9, 3, 0, 0, 0)) }
        @{ Name = '9d1m3h'; Expected = ([timespan]::new(9, 0, 1, 0, 0)) }
        # @{ Name = '-4d2h9s299ms'; Expected = ([timespan]::new(9, 3, 0, 0, 0)) }

    ) {
        Ninmonkey.Console\ConvertTo-Timespan $name -ZeroIsValid
        | Should -Be $expected
        # Get-Emoji -Name $name | Should -Be $expected
    }


}
