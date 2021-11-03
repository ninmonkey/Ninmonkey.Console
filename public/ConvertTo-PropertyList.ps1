
function ConvertTo-PropertyList {
    <#
    .synopsis
        Converts an objects to a hashtable, while selecting properties
    .description
        I forgot what this was supposed to be used for.

        See 'Select-NinProperty' , it's better.

        attempt at safer dynamic properties list.
        often you can instead use:
            Select-Object or *-Csv or *-Json commands

        see also:
            PS> gcm EZOut\ConvertTo-PropertySet
    .notes
        often you can instead use:
            Select-Object or *-Csv or *-Json commands
    .example

        > ls . -File | Get-PropertyList Name, Length
        | Select-First 2

            Name                                                 Length
            ----                                                 ------
            2020-10 showing breakpoints.ps1                         219
            auto run commands list and log -- iter 2 cleanup.ps1   1586
    .example
        $hashList = ls . -file | ConvertTo-PropertyList 'name', 'length'
        $hashList | %{
            $curHash = $_
            $curHash['SizeHuman'] = $curHash['Length'] | Format-FileSize
            [pscustomobject]$curHash
        } | ft -AutoSize

    .example

        (ls . -file)[0] | ConvertTo-PropertyList 'name', 'length'
        $hash['SizeHuman'] = $hash['Length'] | Format-FileSize

        > ls . -File | Get-PropertyList Name, Length -AsHashTable
        | Select-First 1


            Name                           Value
            ----                           -----
            Name                           2020-10 showing breakpoints.ps1
            Length                         219
    .example

        > ls . -File | ConvertTo-PropertyList Name, Length, LastWriteTime -AsHashTable
        | select -First 2
        | % GetEnumerator
        | Join-String -sep "`n" -Property { '{0} = {1}' -f ($_.Key, $_.Value) }
    .link
        Select-NinProperty
    .link
        EZOut\ConvertTo-PropertySet
    #>
    [alias('Select-ObjectProperty-HashTable')]
    param (
        # InputObject
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        # properties to include, uses Select-Object's wildcards syntax
        [Parameter(Mandatory, Position = 0)][string[]]$Property,

        # return a [pscustomobject] instead
        [Parameter()][switch]$AsObject

    )
    begin {}
    process {
        $propList = $_ | Select-Object -Property $Property
        $collectedProp = [ordered]@{}
        $PropList.psobject.Properties | ForEach-Object {
            $collectedProp[ $_.Name ] = $_.Value
        }

        if (! $AsObject) {
            $collectedProp
            return
        }
        [pscustomobject]$collectedProp
    }
    end {}
}
