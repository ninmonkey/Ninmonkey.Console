BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Test-PesterLinesAreEqual" {
    BeforeAll {
        #  test
        $Expected = @(
            'String, Object'
            'Int32, ValueType, Object'
        ) -join "`n"

        $resultStdoutCached = 'String, Object
Int32, ValueType, Object
'
    }
    It 'isEqual if Ignoring Line Endings' {
        Test-PesterLinesAreEqual -ExpectedText $Expected -ActualText $resultStdoutCached
    }
    It 'isNotEqual when Line endings differ' {
        # note: May need to hard-code "`n" as a codepoint, if other platforms differ. (stdout does on windows from "`n")
        { Test-PesterLinesAreEqual -ExpectedText $Expected -ActualText $resultStdoutCached -PreserveLineEnding }
        | SHould -Throw -Because 'Line endings differ'
    }

    Context 'Part2' {
        <#

            $StrNL = [char]::ConvertFromUtf32(0xa) # dec 10
            $StrCR = [char]::ConvertFromUtf32(0xd) # dec 13
            $StrBoth = $StrCR, $StrNL -join ''


            $Sample = 'cat', 'dog'

            # is true on this system:
            #       "`n" -eq "`u{a}"
            $Sample_Default = $Sample -join "`n" # is 0x
            $Sample_CR = $Sample -join $StrCR
            $Sample_NL = $Sample -join $StrNL
            $Sample_CRNL = $Sample -join $StrBoth

            $Sample_Manual = 'cat', [char]::ConvertFromUtf32(0xa), 'dog' -join ''

            $splatStrict = @{
                ExpectedText       = $Sample_Manual
                PreserveLineEnding = $true
                Debug              = $false
            }


            { Test-PesterLinesAreEqual @splatStrict -ActualText $Sample_Default }
            | Should -Not -Throw -Because 'NL = NL'

            { Test-PesterLinesAreEqual @splatStrict -ActualText $Sample_CR }
            | Should -Throw -Because 'CR !+ NL'

            { Test-PesterLinesAreEqual @splatStrict -ActualText $Sample_NL }
            | Should -Not -Throw -Because 'NL = NL'


            if ($false) {

                { Test-PesterLinesAreEqual @splatStrict -ActualText $Sample_CRNL }
                | Should -Throw -Because '?'





                { Test-PesterLinesAreEqual -ExpectedText $Sample_Target -ActualText $Sample_NL -Debug }
                | Should -Not -Throw -Because 'NL == NL'

                { Test-PesterLinesAreEqual -ExpectedText $Sample_Target -ActualText $Sample_CR -Debug }
                | Should -Throw -Because 'NL != CR'

                # { Test-PesterLinesAreEqual -ExpectedText $Sample_Target -ActualText $Sample_NL -Debug } | SHould -Throw -Because 'NL != CR'

                # Test-PesterLinesAreEqual -ExpectedText $Sample_Target -ActualText $Sample_CR -Debug
                # Test-PesterLinesAreEqual -ExpectedText $Sample_Target -ActualText $Sample_CR -Debug
            }
#>
    }
}
