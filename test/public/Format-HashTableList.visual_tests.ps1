
& {
    $SampleList = @(

        @{ expression = 'Name'; Descending = $true; cat = 4 }
        @{ expression = 'Id'; Descending = $true }
    )

    H1 '$list | Format-HashTable -Single'
    $SampleList | Format-HashTable SingleLine

    H1 '$list | Format-HashTable'
    $SampleList | Format-HashTable


    H1 ',$list | Format-HashTable'  -fg green
    , $SampleList | Format-HashTableList

    H1 '$list | Format-HashTableList'
    $SampleList | Format-HashTableList

}