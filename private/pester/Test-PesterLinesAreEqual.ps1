function Test-PesterLinesAreEqual {
    <#
    .synopsis
        test if strings are equa
        l, regardless of line ending style
    .notes
        - Is it better to throw an exception or return a [bool] for [Pester] ?
        - if the text delim is '\r' with no '\n' then splitting on '\r?\n' fails
    #>
    param(
        # Expected Text
        [Parameter(Mandatory, Position = 0)]
        [string[]]$ExpectedText,

        # Comparison text
        [Parameter(Mandatory, Position = 1)]
        [string[]]$ActualText,

        # strict coompare: Treat different line endings as a failed match
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
        $cleanActual | Should -Be $cleanExpected
    }
}
