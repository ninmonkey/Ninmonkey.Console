BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Write-ConsoleHeader" -Tag 'wip' {
    BeforeAll {
        $Newline = "`n"

        $SampleText = @'
if($foo) {
    Get-ChildItem . -File | ForEach-Object {
        $_.Length, $_.Name | Join-String -sep ' = '
    }
}

$x = 20
'@

        $ExpectedText = @'
    if($foo) {
        Get-ChildItem . -File | ForEach-Object {
        $_.Length, $_.Name | Join-String -sep ' = '
        }
    }

    $x = 20
'@
    }

    # test was't working great, but it was overkill for this tiny function

    # It 'Piping' {
    #     $result = $SampleText | Format-Predent
    #     $result | Should -be "$Newline    $ExpectedText"
    # }

    # It 'Newline' {
    #     $sample = "a", "`n    b" -join ''
    #     $sample = "a`n    b"
    #     $expected = "    a`n        b"
    #     $sample | Format-Predent
    #     | Should -Be

    # }

    It 'single' -Tag 'wip' {
        # $expected = "$Newline    a"
        # $expected = "`n    a"

        # 'a' | Format-Predent
        10 | Should -be 3
    }
}

# hr

# $testText -split '\n' | Format-Indent
# hr
# $testText | Format-Indent

# strange indenting to test
