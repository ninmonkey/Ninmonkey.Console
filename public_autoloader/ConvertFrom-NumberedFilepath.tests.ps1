BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'ConvertFrom-NumberedFilepath' -Skip {
    It 'Does not throw' {
        { 'adsfs' | ConvertFrom-NumberedFilepath }
        | Should -Not -Throw
    }

    Describe 'Format -As [VSCodeFilepath]' {
        It 'Text: Valid filepath' {
            Set-ItResult -Pending -Because 'needs to be created/merged / nyi'
            # '...' | Should -BeOfType ([VSCodeFilepath])
        }
        # $result  =
    }

    Describe 'AnsiEscapes' {
        It 'FromRipGrep' {
            Set-ItResult -Skipped -Because 'add handling piping from RipGrep using StripAnsi()'
        }
    }

    It 'DefaultArgs: "<Text>" = "<Expected>"' -ForEach @(
        @{
            Text     = 'foo:bar:cat.ps1:345:4'
            Expected = 'foo:bar:cat.ps1'
        }
        @{
            Text     = 'foo:bar:cat.ps1:345'
            Expected = 'foo:bar:cat.ps1'
        }
        @{
            Text     = 'foo:bar:cat.ps1'
            Expected = 'foo:bar:cat.ps1'
        }
    ) {
        $Text | ConvertFrom-NumberedFilepath -StripLastOnly:$False
        | Should -Be $Expected
    }
    It 'StripLastOnly: "<Text>" = "<Expected>"' -ForEach @(
        @{
            Text        = 'foo:bar:cat.PS1:345:4'
            Expected    = 'foo:bar:cat.PS1:345'
            ShouldThrow = $False
        }
        @{
            Text        = 'foo:bar:cat.PS1:345:4'
            Expected    = 'foo:bar:cat.PS1:345'
            ShouldThrow = $False
        }
    ) {
        if ($ShouldThrow ?? $false) {
            { $Text | ConvertFrom-NumberedFilepath -StripLastOnly }
            | Should -Throw -Because 'Invalid result'

        }

        $Text | ConvertFrom-NumberedFilepath -StripLastOnly
        | Should -Be $Expected
    }
}
