BeforeAll {
    # 1] either run adjacent file  (foo.tests.ps1 -> foo.ps1)
    #. $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    # 2] or if you're using multiple commands
    Import-Module 'Ninmonkey.Console' -Force # Dev.Nin -Force # Is this the correct way to import
    # $ErrorActionPreference = 'stop' #'break'
}

Describe 'Format-ControlChar' {
    BeforeAll {
        # the first 51 codepoints
        $sampleRunes = 0..50 | ForEach-Object {
            [char]::ConvertFromUtf32( $_ )
        }
        $NullStr = '␀' # "`u{2400}"

    }
    Describe 'Nullable values' {
        It 'Null Char' {
            [char]::ConvertFromUtf32(0) | Format-ControlChar
            | Should -Be $NullStr
        }
        It '$Null Value' {
            $null | Format-ControlChar | Should -Be $NullStr
            Format-ControlChar -InputText $null | Should -Be $NullStr
        }
    }
    Describe 'Allow Whitespace' {
        $NullStr = '␀' # was not in this scope?
        $Sample = "`n`ncat`t"
        It "'<Sample>' and whitespace <Whitespace>? Returns<Expected>" -ForEach @(
            @{ Sample = "`t`tcat`n" ; Whitespace = $false ; Expected = '␉␉cat␊' }
            @{ Sample = "`t`tcat`n" ; Whitespace = $true ; Expected = "`t`tcat`n" }
        ) {
            $Sample | Format-ControlChar -PreserveWhitespace:$Whitespace
            | Should -Be $Expected -Because 'Manually generated test case'

        }


        # forIt '"<Sample>" Returns "<expected>"' -ForEach @(
        #     @{ Sample = x ; Expected = y }
        # ) {
        #     . $__PesterFunctionName $Sample | Should -Be $Expected
        # }

        It 'Test First 50 codepoints' {
            $sampleRunes = 0..50 | ForEach-Object {
                [char]::ConvertFromUtf32( $_ )
            }
            $expected = '␀␁␂␃␄␅␆␇␈␉␊␋␌␍␎␏␐␑␒␓␔␕␖␗␘␙␚␛␜␝␞␟␠!"#$%&''()*+,-./012'

            $result = $sampleRunes | Format-ControlChar
            $result | Should -Be $Expected
        }
        # It '"<TestString>" Returns "<expected>"' -ForEach @(
        #     @{ TestString = $null ; Expected = $NullStr }
        # ) {
        #     $TestString | Format-ControlChar | Should -Be $Expected
        # }
    }
}
