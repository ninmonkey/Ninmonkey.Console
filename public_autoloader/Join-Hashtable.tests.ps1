BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'Join-Hashtable' {
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
