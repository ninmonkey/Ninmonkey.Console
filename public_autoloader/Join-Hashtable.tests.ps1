BeforeAll {
    Import-Module Ninmonkey.Console -Force
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
