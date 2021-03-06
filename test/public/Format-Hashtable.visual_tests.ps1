﻿# BeforeAll {
#     . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
# }

# Describe "Format-HashTable" -Tag 'wip', 'wip-hash' {
#     BeforeAll {
#         $hash1 = @{ c = 'Jack'; a = 'Cat'; b = 12 }#
#     }

#     It 'Test hashtable ordering' -Tag 'Visual', 'ANSI', 'Formatting' {
#         $hash1 | Format-HashTable Pair
#     }

# }

$hash1 = @{ c = 'Jack'; a = 'Cat'; b = 12 }

h1 'pair'
$hash1 | Sort-Hashtable | Format-HashTable Pair
h1 'pair -Descending'
$hash1 | Sort-Hashtable -Descending | Format-HashTable Pair

h1 'singleLine'
$hash1 | Sort-Hashtable | Format-HashTable SingleLine
h1 'singleLine -Descending'
Write-Warning 'may not be trivial for this formatter to be ordered'
$hash1 | Sort-Hashtable -Descending | Format-HashTable SingleLine

$hash1 | Sort-Hashtable | Format-HashTable Table
hr
$hash1 | Sort-Hashtable -Descending | Format-HashTable Table

hr

#Import-Module Ninmonkey.Console -Force
$hash1 = @{ name = 'Jack'; species = 'Cat'; age = 12 }
$hash1 | Sort-Hashtable -Descending
| Format-HashTable Pair
hr
$hash1 | Sort-Hashtable
| Format-HashTable Pair -NoSortKeys
hr
& {
    Label 'Test Table to Debug Stream'
    $DebugPreference = 'Continue'
    hr
    $hash1
    hr
    $hash1 | Sort-Hashtable
    | Format-HashTable Table
    | Write-Debug
    hr
    h1 'final'

    h2 'format only'
    $hash1 | Format-HashTable Table

    h2 'format to debug'
    $hash1 | Format-HashTable Table | Label 'hash1' -fg2 white
    | Write-Debug
}