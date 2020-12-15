BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Sort-Hashtable" -Tag 'wip', 'wip-hash' {
    BeforeAll {
        $hash1 = @{ c = 'Jack'; a = 'Cat'; b = 12 }
        $Expected = @{
            SortKeyAsc   = @{
                FirstKey = 'a'
                LastKey  = 'c'
            }
            SortValueAsc = @{
                FirstValue = '12'
                LastValue  = 'Jack'
            }
        }
    }

    It 'Sort: mixed types so not throw' {
        $hash = @{ 'one' = 1; 1 = 'one' }
        { $hash | Sort-Hashtable }
        | Should -Not -Throw
    }

    It 'Sort: mixed types' {
        $hash = @{
            'one' = 1;
            1     = 'one'
        }
        $expectedSort = [ordered]@{
            1     = 'one'
            'one' = 1
        }
        $orderedHash = $hash | Sort-Hashtable

        $orderedHash[0] | Should -Be $expectedSort[0]
        $orderedHash[1] | Should -Be $expectedSort[1]

    }

    It 'Sort: Key: Ascending' {
        $sorted = $hash1 | Sort-Hashtable

        $sorted.Keys | Select-Object -First 1
        | Should -Be $Expected.SortKeyAsc.FirstKey

        $sorted.Keys | Select-Object -Last 1
        | Should -Be $Expected.SortKeyAsc.LastKey
    }

    It 'SortBy: Key, Descending' {
        $sorted = $hash1 | Sort-Hashtable Key -Descending

        $sorted.Keys | Select-Object -First 1
        | Should -Be $Expected.SortKeyAsc.LastKey

        $sorted.Keys | Select-Object -Last 1
        | Should -Be $Expected.SortKeyAsc.FirstKey
    }

    It 'SortBy: Value, Ascending' {
        $sorted = $hash1 | Sort-Hashtable Value

        $sorted.Values | Select-Object -First 1
        | Should -Be $Expected.SortValueAsc.FirstValue

        $sorted.Values | Select-Object -Last 1
        | Should -Be $Expected.SortValueAsc.LastValue
    }

    It 'SortBy: Value, Descending' {
        $sorted = $hash1 | Sort-Hashtable Value -Descending

        $sorted.Values | Select-Object -First 1
        | Should -Be $Expected.SortValueAsc.LastValue

        $sorted.Values | Select-Object -Last 1
        | Should -Be $Expected.SortValueAsc.FirstValue
    }
}