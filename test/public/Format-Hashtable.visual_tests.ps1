# BeforeAll {
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