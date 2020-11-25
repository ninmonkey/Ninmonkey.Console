
function ConvertTo-PropertyList {
    <#
    .synopsis
        Returns a hashtable of specific properties
    .description
        name? ConvertTo-PropertyList ?
        attempt at safer dynamic properties list
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
    #>
    [alias('ConvertTo-HashTable')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        [Parameter(
            Mandatory, Position = 0,
            HelpMessage = 'names of properties, the default uses an exact match')]
        [string[]]$Property,

        [Parameter(HelpMessage = "return a [pscustomobject] instead")]
        [switch]$AsObject

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
