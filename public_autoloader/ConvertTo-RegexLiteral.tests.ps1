#requires -modules @{ModuleName='Pester';ModuleVersion='5.0.0'}
BeforeAll {
    Import-Module Ninmonkey.Console -Force
    # $ErrorActionPreference = 'Stop'
}

Describe 'ConvertTo-RegexLiteral' -Tag Unit {
    BeforeAll {

    }
    It 'Runs without error' {
        { ConvertTo-RegexLiteral 'stuff', 'other' }
        | Should -Not -Throw

        { 'stuff', 'other' | ConvertTo-RegexLiteral 'stuff', 'other' }
        | Should -Not -Throw
    }
    It 'Whitespace for "<Label>" is "<Expected>"' -ForEach @(
        @{
            Sample   = 'ab.$#@'
            Label    = 'ab.$#@'
            expected = 'ab\.\$\#@'
        }
        @{
            Sample   = 'z2341-0'
            Label    = 'z2341-0 nothing to escape'
            expected = 'z2341-0'
            # // --StartsWith] [-EndsWith] [-Enclose
        }
        @{
            Sample   = 'z2341-0'
            Label    = 'ab.$#@'
            expected = 'z2341-0'

        }
        @{
            Sample   = 'foo.png'
            Label    = 'foo.png'
            expected = 'foo\.png$'
            Extra    = @{
                EndsWith = $True
                # StartsWith = $True
                # Enclose = $True
            }
            # -StartsWith] [-EndsWith] [-Enclose

        }
        @{
            Sample   = '.git'
            Label    = '.git'
            expected = '\.git$'
            Extra    = @{
                EndsWith = $True
                # StartsWith = $True
                # Enclose = $True
            }
            # -StartsWith] [-EndsWith] [-Enclose

        }
    ) {
        $Extra ??= @{} # simplifies hash splatting
        $Sample
        | RegexLiteral @Extra
        | Should -Be $Expected -Because 'Manually written tests'

    }
}
