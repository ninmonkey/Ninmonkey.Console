BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Test-PesterLinesAreEqual" {
    BeforeAll {
        #  test

        $StrNL = [char]::ConvertFromUtf32(0xa) # dec 10
        $StrCR = [char]::ConvertFromUtf32(0xd) # dec 13
        $StrBoth = $StrCR, $StrNL -join ''

        $Sample_List = 'cat', 'dog'

        $Sample_Default = $Sample_List -join "`n" # is 0x
        $Sample_CR = $Sample_List -join $StrCR
        $Sample_NL = $Sample_List -join $StrNL
        $Sample_CRNL = $Sample_List -join $StrBoth
        $Sample_Manual = 'cat', [char]::ConvertFromUtf32(0xa), 'dog' -join ''

        $resultStdoutCached = 'String, Object
Int32, ValueType, Object
'
        $Expected = @(
            'String, Object'
            'Int32, ValueType, Object'
        ) -join "`n"

        $splat_CompareStrict = @{
            ExpectedText       = $Sample_Manual
            PreserveLineEnding = $true
            Debug              = $false
        }
        $splat_CompareLoose = @{
            ExpectedText       = $Sample_Manual
            PreserveLineEnding = $false
            Debug              = $false
        }
        # this is true on this system:
        #       "`n" -eq "`u{a}"
    }
    It 'isEqual if Ignoring Line Endings' {
        Test-PesterLinesAreEqual -ExpectedText $Expected -ActualText $resultStdoutCached
    }
    It 'isNotEqual when Line endings differ' {
        { Test-PesterLinesAreEqual -ExpectedText $Expected -ActualText $resultStdoutCached -PreserveLineEnding }
        | Should -Throw -Because 'Line endings differ'
    }

    Context 'Strict Compare: Line Endings' {
        It 'Default' {
            { Test-PesterLinesAreEqual @splat_CompareStrict -ActualText $Sample_Default }
            | Should -not -Throw -Because '"`n" == NL'
        }
        It 'NL' {
            { Test-PesterLinesAreEqual @splat_CompareStrict -ActualText $Sample_Manual }
            | Should -not -Throw -Because 'NL == NL'
        }
        It 'CR' {
            { Test-PesterLinesAreEqual @splat_CompareStrict -ActualText $Sample_CR }
            | Should -Throw -Because 'CR != NL'
        }
        It 'CRNL' {
            { Test-PesterLinesAreEqual @splat_CompareStrict -ActualText $Sample_CRNL }
            | Should -Throw -Because 'CRNL != NL'
        }
    }
    Context 'Loose Compare: LineEndings' {
        It 'Default' {
            { Test-PesterLinesAreEqual @splat_CompareLoose -ActualText $Sample_Default }
            | Should -not -Throw -Because '"`n" ~= NL'
        }
        It 'NL' {
            { Test-PesterLinesAreEqual @splat_CompareLoose -ActualText $Sample_Manual }
            | Should -not -Throw -Because 'NL ~= NL'
        }
        It 'CR' {
            { Test-PesterLinesAreEqual @splat_CompareLoose -ActualText $Sample_CR }
            | Should -Throw -Because 'splitting on "\?r\n" fails if there are no newlines'
        }
        It 'CRNL' {
            { Test-PesterLinesAreEqual @splat_CompareLoose -ActualText $Sample_CRNL }
            | Should -not -Throw -Because 'CRNL ~= NL'
        }
    }
}
