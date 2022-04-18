$script:publicToExport.function += @(
    'Merge-HashtableList'
)
# $script:publicToExport.alias += @(
# 'HelpCommmand')


Function Merge-HashtableList {
    <#
    .description
        from the pipeline, merge all hastables in-order
    .notes
        .
    .example
    🐒> ls . -file | select -First 4 | %{
    $_ | Lookup 'Length' -NewKeyName 'Size'
    $_ | Lookup 'LastWriteTime' -NewKeyName 'Updated'
    @{ 'randomProperty' = 'cats'}
    get-date | dict day\b
    } | Merge-HashtableList -AsObject | ft -AutoSize

        TimeOfDay        Size Updated              Day randomProperty
        ---------        ---- -------              --- --------------
        11:16:58.6575367  253 3/14/2021 5:17:30 PM  19 cats
    .example
    🐒>
        ls . -file | select -First 4 | %{
            $_ | Lookup 'Length' -NewKeyName 'Size'
            $_ | Lookup 'LastWriteTime' -NewKeyName 'Updated'
            @{ 'randomProperty' = 'cats'}
            get-date | dict day\b
        } | Merge-HashtableList

            Name           Value
            ----           -----
            TimeOfDay      11:11:14.3477747
            Size           253
            Updated        3/14/2021 5:17:30 PM
            Day            19
            randomProperty cats

    .link
        Ninmonkey.Console\Join-Hashtable
    .link
        Ninmonkey.Console\Merge-HashtableList
    .link
        PSScriptTools\Join-Hashtable
    .link
        Ninmonkey.Powershell\Join-Hashtable
    #>
    [outputType('System.Collections.Hashtable')]
    [cmdletbinding()]
    param(
        # base hashtable
        [Alias('$Hashtable')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [hashtable[]]$InputObject,

        # use ordered hashtables instead?
        [switch]$Ordered,

        # This will return a [pscustomobject], instead of [hashtable]
        [switch]$AsObject
    )
    begin {
        $tables = [list[hashtable]]::new()
        write-warning 'old codo, needs at leat a look'
    }
    # don't mutate $BaseHash
    process {
        if ($Ordered) {
            Write-Error -Category NotImplemented -Message 'nyi' -ErrorId 'MergeHashtableParamOrered'
            return
        }

        foreach ($hash in $InputObject) {
            $tables.Add( $hash )
        }
    }
    end {
        $accum = @{}
        foreach ($hash in $tables) {
            $accum = Ninmonkey.Console\Join-Hashtable -BaseHash $accum -UpdateHash $hash
        }
        if ($AsObject) {
            [pscustomobject]$accum
        } else {
            $accum
        }
    }
}
