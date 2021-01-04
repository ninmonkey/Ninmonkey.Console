function Test-PesterLinesAreEqual {
    <#
    .synopsis
        test if strings are equal, regardless of line ending style
    #>
    param(
        # Expected Text
        [Parameter(Mandatory, Position = 0)]
        [string[]]$ExpectedText,

        # Comparison text
        [Parameter(Mandatory, Position = 1)]
        [string[]]$ActualText,

        # this will throw an error when there are newlines verses line feed
        [Parameter()][switch]$PreserveLineEnding
    )
    process {
        # H1 "_Pester-linesAreEqual" | Write-Information
        $Meta = @{
            'PreserveLineEndings?' = $PreserveLineEnding
            ExpectedLength         = ($ExpectedText -join '' ).Length
            ActualLength           = ($ActualText -join '' ).Length
        }

        $cleanExpected = $ExpectedText.Trim()
        if (! $PreserveLineEnding) {
            $cleanExpected = $cleanExpected -join "`n" -split '\r?\n' -join "`n"
        }
        $cleanActual = $ActualText.Trim()
        if (! $PreserveLineEnding) {
            $cleanActual = $cleanActual -join "`n" -split '\r?\n' -join "`n"
        }
        $Meta += @{
            ExpectedLengthClean = ($cleanExpected -join '' ).Length
            ActualLengthClean   = ($cleanActual -join '' ).Length
        }

        $Meta | Format-HashTable | Write-Debug

        # $cleanActual = $ActualText.Trim()

        # -join "`n" -split '\r?\n' -join "`n"

        # $ExpectedText | Should -Be $ActualText
        # ($cleanActual -eq $cleanExpected) | Should -Be $rue

        $cleanActual | Should -Be $cleanExpected
        # $cleanActual | Should -Be $cleanExpected
    }
}
