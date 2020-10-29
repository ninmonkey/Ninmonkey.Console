BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

<#
add:

if ($true) {
    # need to test: should test
    # 'System.System.System' | Format-TypeName -IgnorePrefix 'System' -ea Continue
    'system.text'.GetType() | Format-TypeName

}
#>

Describe "Format-NullText" -tags 'Console_Output', 'wip' {
    Context 'Single Values' {
        BeforeAll {
            $Uni = {
                Null       = "`u{0}"
                NullSymbol = '␀'
            }
        }
        It 'Return Int' {
            10 | Format-NullText | Should -be 10
        }

        It 'Return Int' {
            $Expected = 10, '', " ", $Uni.NullSymbol, $Uni.NullSymbol
            $Values = 10, '', " ", $null, $Uni.Null
            $Values | Format-NullText
            | Should -be $Expected
        }




        # | Format-Table

        # $null | Format-NullText
        # , $null | Format-NullText
        # Format-NullText $null
    }

}
