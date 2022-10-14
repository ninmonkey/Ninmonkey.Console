BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'Join-Hashtable Rewrite' {
    BeforeAll {
        $sample = @(
            @{a = 2}
            @{a = 3 ; z = 0 }
        )

    }
    it 'toFix: ParamSets' {
        {
            $base = @{a = 1}
            $expected =  @{ a = 3; z = 0 }

            $sample
            | Join-Hashtable -BaseHash $base
        } | Should -not -Throw
    }
    it 'static' {
        $base = @{a = 1}
        $expected =  @{ a = 3; z = 0 }

        $res = $sample | Join-Hashtable -BaseHash $base

        $res -is 'hashtable' -or  $res -is 'System.Collections.Specialized.OrderedDictionary'
        | Should -be $True -because 'Should Be dictionary-like type'

        $res.a | SHould -be 3
        $res.z | Should -be 0

        # | Should -BeExactly $expected
        # System.Collections.Specialized.OrderedDictionary
    }
    it 'AsPipe' {
        $base = @{a = 1}
        $expected =  @{ a = 3; z = 0 }

        $sample
        | Join-Hashtable -BaseHash $base
        | Should -BeExactly $expected
    }
    it 'HardCoded Pipeline' {
        $res = @(
            @{a=1; z=1}
            @{a=2}
        ) | Join-Hashtable -BaseHash @{ a=0; b=0}

        $res.a | SHould -be 2
        $res.b | SHould -be 0
        $res.z | SHould -be 1
    }
    Context 'ParamSet Runs Without Throw' {
        it 'FromPipe' {
            {
                @{ a = 1 } | Join-hashtable -BaseHash @{ a = 0; b = 0 }
            } | Should -not -Throw

            {
                @( @{ a = 1 }; @{ b = 2 } )
                | Join-hashtable -BaseHash @{ a = 0; b = 0 }
            } | Should -not -Throw
        }
    }

}

Describe 'Join-Hashtable' {
    Context 'Parameters are optional' {

        It 'No Argument' {
            { Join-Hashtable -BaseHash @{ a = 3 } -ea stop }
            | Should -Not -Throw

        }
        It 'Empty Hash' {
            {
                $other = @{}
                Join-Hashtable -BaseHash @{ a = 3 } -OtherHash $other -ea stop
            }
            | Should -Not -Throw
        }
        It '$Null hash' {
            {
                $other = $Null
                Join-Hashtable -BaseHash @{ a = 3 } -OtherHash $other -ea stop
            }
            | Should -Not -Throw
        }
    }
    It 'try mutation' -Pending {
        @(
            $defaults = @{Name = 'NoUser' }
            $player = @{Name = 'fred' ; Flag = $true }

            $defaults | Format-Dict | label 'default'
            $player | Format-Dict | label 'player'
            $new = Join-Hashtable $defaults $player
            $new | Format-Dict | Label '$new'

            $DefaultConfig = @{font = 12 }
            $DefaultConfig | format-dict | label '$Base defaults'
            Join-Hashtable -MutateLeft -BaseHash $defaults -UpdateHash $player | Format-Dict | label 'result of func call'
            $DefaultConfig | format-dict | label '$Base after mutated?'
        ) | Write-Host

        $true | Should -Be $true
    }
}
