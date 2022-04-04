BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'Format-RemoveAnsiEscape' {
    It 'Hardcode Color' {
        [rgbcolor]'#FFC0CB' | ForEach-Object { $_ | write-color $_ } | Format-RemoveAnsiEscape
        | Should -BeExactly '#FFC0CB' -Because 'Ansi Escapes should have been removed'
    }

    It 'Colorized Path Loads' {
        {
            Get-Item . | ForEach-Object fullname
            | Dev.Nin\Write-Color 'blue'
            | StripAnsi | Get-Item -ea stop
        } | Should -Not -Throw -Because 'if only colors are removed, it''s a valid item'
    }
}
