BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
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
        # $ErrorActionPreference = 'break'
    }
    Describe 'Empty Values' {
        It 'Zero is Valid' {
            { RelativeTs '0s' -ZeroIsValid:$True } | Should -Not -Throw
        }
        It 'Zero Should Throw' {
            { RelativeTs '0s' -ZeroIsValid:$false } | Should -Throw
        }
    }
    It 'Returns <expected> (<name>)' -ForEach @(
        # I think some values go out of range or precision errors
        @{ Name = '3d1m'; Expected = ([timespan]::new(3, 0, 1, 0, 0)) }
        @{ Name = '9d3h'; Expected = ([timespan]::new(9, 3, 0, 0, 0)) }
        @{ Name = '9d3h1d'; Expected = ([timespan]::new(9, 3, 0, 0, 0)) }
        @{ Name = '9d1m3h'; Expected = ([timespan]::new(9, 0, 1, 0, 0)) }
        # @{ Name = '-4d2h9s299ms'; Expected = ([timespan]::new(9, 3, 0, 0, 0)) }

    ) {
        ConvertTo-Timespan $name
        | Should -Be $expected
        # Get-Emoji -Name $name | Should -Be $expected
    }


}
