
<#
    NYI: Test the results of these
if ($false) {
    # tests
    10, '', " ", $null, "`u{0}" | Test-NullArg -ov 'lastRes' -Verbose
    | Format-Table
    $res = @()
    $res += $null | Test-NullArg
    $res += , $null | Test-NullArg
    $res += Test-NullArg $null
    $res | Format-Table
}

#>