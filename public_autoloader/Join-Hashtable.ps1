$script:publicToExport.function += @(
    'Join-Hashtable'
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
            $accum = Join-Hashtable -BaseHash $accum -UpdateHash $hash
        }
        if ($AsObject) {
            [pscustomobject]$accum
        } else {
            $accum
        }
    }
}

Function Join-Hashtable {
    <#
    .description
        Copy and append BaseHash with new values from UpdateHash
    .notes
        future: add valuefrom pipeline to $UpdateHash param ?
    .example
        Join-Hashtable -Base $
    .link
        Ninmonkey.Console\Join-Hashtable
    .link
        Ninmonkey.Console\Merge-HashtableList
    .link
        Ninmonkey.Powershell\Join-Hashtable
    .link
        PSScriptTools\Join-Hashtable
    #>
    [cmdletbinding()]
    [outputType('System.Collections.Hashtable')]
    param(
        # base hashtable
        [Parameter(Mandatory, Position = 0)]
        [hashtable]$BaseHash,

        # New values to append and/or overwrite
        [Parameter(Mandatory, Position = 1)]
        [hashtable]$OtherHash,

        # normal is to not modify left, return a new hashtable
        [Parameter()][switch]$MutateLeft

        # default Left wins if they share a key name
        # [Parameter()][switch]$PrioritizeRight
    )

    # don't mutate $BaseHash
    process {
        # $NewHash = [hashtable]::new( $BaseHash )
        if (! $MutateLeft ) {
            $TargetHash = [hashtable]::new( $BaseHash )
        } else {
            Write-Debug 'Mutate enabled'
            $TargetHash = $BaseHash
        }
        $OtherHash.GetEnumerator() | ForEach-Object {
            $TargetHash[ $_.Key ] = $_.Value
        }
        $TargetHash
    }
}
