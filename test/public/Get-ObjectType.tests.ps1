BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-ObjectType" {
    BeforeAll {
    }

    It 'NotCreatedTests' {
        $true | Should -Be $False -Because 'Tests not written yet'

        'sdf' | TypeOf | Format-List
        'sdf' | TypeOf -All | Format-List
        c:\Users\cppmo_000\Docum
        'sdf' | TypeOf -All | Format-List
        'sdf' | TypeOf
        'sdf' | TypeOf -All
        'a', 2 | TypeOf -All
        ('a', 2) | TypeOf -All
        ('a', 2) | TypeOf -All
        , ('a', 2) | TypeOf -All
    }


    It 'singleLine' {
        # $expected = "$Newline    a"
        $expected = "`n    a"

        'a' | Format-Predent -PassThru
        | Should -be $expected
    }

    # It 'from clipboard array' -Tag 'wip' {
    # }

    #     It 'multiLine' -Tag 'wip' {
    #         $sample = @'
    # $stuff = $false
    # if($stuff) {
    #     foo {
    #         bar
    #     }
    # }
    # '@
    #         $expected = @'
    #     $stuff = $false
    #     if($stuff) {
    #         foo {
    #             bar
    #         }
    #     }
    # '@ -split '\r?\n' -join "`n"
    #         # $sample -join

    #         $sample | Format-Predent -PassThru
    #         | Should -be $expected
    #     }

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

}

# hr

# $testText -split '\n' | Format-Indent
# hr
# $testText | Format-Indent

# strange indenting to test
