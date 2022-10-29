if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'Join-Hashtable'
        'Join-Hashtable.basic'

        # sort-of-private
        'sortedHashtable'
        'mergeHashtable'
    )
}

function sortedHashtable {
    # converts existing hash into a new, sorted hash
    param()
    throw "NYI: super simple though"

}

# Function Join-Hashtable.basic {
Function Join-Hashtable {
    <#
    .description
        the simplified, previous implementation of 'Join-Hashtable'
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
        [AllowNull()]
        [Parameter(Position = 1)]
        [hashtable]$OtherHash,

        # normal is to not modify left, return a new hashtable
        [Parameter()][switch]$MutateLeft
    )

    # don't mutate $BaseHash
    process {
        $OtherHash ??= @{}
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


<#
old examples for previous  Join-Hashtablelist
    .description
        from the pipeline, merge all hastables in-order
    .notes
        .this should join with 'join-hashtable' to be a single command
        the *other* command is if I want to mutate the first
    .example


    .link
        Ninmonkey.Console\Join-Hashtable
    .link
        Ninmonkey.Console\Merge-HashtableList
    .link
        PSScriptTools\Join-Hashtable
    .link
        Ninmonkey.Powershell\Join-Hashtable
#>

<#
to ask

    - <file:///C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Ninmonkey.Console\public_autoloader\Join-Hashtable.ps1>

ask
- does ExpectingInput() or input pipeline done
- [1] allowe cleaner paramsets (or logic) ?

- [2] does 'end-of-pipeline' let you  enable smart formatting, instead of

#>


Function Join-Hashtable.new {
    <#
    .description
        Updates default values if any keys collide. BaseHash is the default, its values are updated.
    .notes

        todo: allow pipeline
            $hash1, $hash2 | Join-Hashtable -base $BaseHash

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
        # [ValidateNotNull()]
        # [AllowNull()]
        [ValidateNotNull()]
        [Parameter(Mandatory, ParameterSetName = 'FromParams')]
        [Parameter(Mandatory, ParameterSetName = 'FromPipeline')]
        [hashtable]$BaseHash,

        # one or many hashtables, applied order
        [AllowNull()]
        [Alias('InputObject')]
        [Parameter(Mandatory, ParameterSetName = 'FromParams')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromPipeline')]
        [hashtable[]]$OtherHash,

        # default  is to not modify the base hash, returns a new one
        [Alias('MutateBase')]
        [Parameter()][switch]$MutateLeft,

        # Change the default compare mode on the new hash. Default is insensitive to align with @{} defaults.
        [ArgumentCompletions( #todo: make re-usable string comparer transformation attribute
            'InvariantCulture',
            'InvariantCultureIgnoreCase',
            'CurrentCulture',
            'CurrentCultureIgnoreCase',
            'Ordinal',
            'OrdinalIgnoreCase' )]
        [System.StringComparer]
        [Parameter()]$ComparerType = [StringComparer]::CurrentCultureIgnoreCase
    )

    begin {
        [hashtable]$state = @{}
    }
    process {
        if($PSCmdlet.ParameterSetName  -eq 'FromParams') { return } # explicit defaults
        foreach($hash in $OtherHash) {
            if($null -eq $hash) { continue }  # $hash ??= @{}
            # $OtherHash ??= @{}
            $state = Ninmonkey.Console\mergeHashtable -BaseHash $state -OtherHash $hash -MutateLeft:$MutateLeft -ComparerType $ComparerType
        }
    }
    end {
        if($PSCmdlet.ParameterSetName  -eq 'FromPipeline') { return $state } # explicit defaults

        foreach($hash in $OtherHash) {
            if($null -eq $hash) { continue }  # $hash ??= @{}
            # $OtherHash ??= @{}
            $state = Ninmonkey.Console\mergeHashtable -BaseHash $state -OtherHash $hash -MutateLeft:$MutateLeft -ComparerType $ComparerType
        }
        return $state
    }
}

Function mergeHashtable {
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
    # [Alias('mergeHashtable')]
    [OutputType('System.Collections.Hashtable')]
    [cmdletbinding()]
    [outputType(
        'System.Collections.Hashtable'
        # 'System.Collections.Specialized.OrderedDictionary' # not currently, but may
    )]
    param(
        # base hashtable
        # [ValidateNotNull()] # ?
        [AllowNull()]
        [Parameter(Mandatory)][hashtable]$BaseHash,

        # New values to append and/or overwrite
        # or allow null, coerce to empty hash ?
        # [ValidateNotNull()]
        [AllowNull()]
        [Parameter(Mandatory)][hashtable]$OtherHash,

        # default is case-insensitive, to align with regular defaults
        [ArgumentCompletions(
            'InvariantCulture', # todo: make re-usable string comparer transformation attribute
            'InvariantCultureIgnoreCase',
            'CurrentCulture',
            'CurrentCultureIgnoreCase',
            'Ordinal',
            'OrdinalIgnoreCase' )]
        [System.StringComparer]
        [Parameter()]$ComparerType = [StringComparer]::CurrentCultureIgnoreCase,

        # normal is to not modify left, return a new hashtable
        [Parameter()][switch]$MutateLeft
    )

        $BaseHash ??= @{}
        $OtherHash ??= @{}

        if (! $MutateLeft ) {
            $TargetHash = [hashtable]::new( $BaseHash, $ComparerType )
        } else {
            Write-Debug 'Mutate enabled'
            $TargetHash = $BaseHash
        }
        $OtherHash.GetEnumerator() | ForEach-Object {
            $TargetHash[ $_.Key ] = $_.Value
        }

        return $TargetHash
}

