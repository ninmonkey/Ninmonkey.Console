if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'Join-Hashtable'
        'Join-Hashtable.basic'
        'Join-Hashtable.new'

        # sort-of-private
        'sortedHashtable'
        'mergeHashtable'
    )
    $script:publicToExport.alias += @(
        'JoinHash'  # 'Join-Hashtable
        'JoinHash2' # 'Join-Hashtable.new'
    )
}

function sortedHashtable {
    #  new.sortedHash
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
    [Alias('JoinHash')]
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

        $a = @{ a = 9 ; b = 4 ; z = 4; }
        $b = @{ z = 9 }
        $d = @{ a = 1 }

        $a, $b, $d | Join-Hashtable.new
        $a, $b | Join-Hashtable.new -BaseHash $d



    .link
        Ninmonkey.Console\Join-Hashtable
    .link
        Ninmonkey.Console\Merge-HashtableList
    .link
        Ninmonkey.Powershell\Join-Hashtable
    .link
        PSScriptTools\Join-Hashtable
    #>
    [Alias('JoinHash2')]
    [cmdletbinding()]
    [outputType('System.Collections.Hashtable')]
    param(
        # base hashtable
        # [ValidateNotNull()]
        # [AllowNull()]
        [ValidateNotNull()]
        [Parameter(Mandatory, ParameterSetName = 'FromParams')]
        [Parameter(ParameterSetName = 'FromPipeline')]
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
        - todo: [ ] ImmutableDictionary
        - future: add valuefrom pipeline to $UpdateHash param ?

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
    [Alias('UpdateHash')]
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
        # [ArgumentCompletions(
        #     'InvariantCulture', # todo: make re-usable string comparer transformation attribute
        #     'InvariantCultureIgnoreCase',
        #     'CurrentCulture',
        #     'CurrentCultureIgnoreCase',
        #     'Ordinal',
        #     'OrdinalIgnoreCase' )]
        # [System.StringComparer]
        # [Parameter()]$ComparerType = [StringComparer]::CurrentCultureIgnoreCase,

        [Alias('StringComparer')]
        [Parameter()]
        [ArgumentCompletions(
            # to rebuild, run: [StringComparer] | fime -MemberType Property | % Name | sort -Unique | join-string -sep ",`n" -SingleQuote
            # todo: make re-usable string comparer transformation attribute, if PSRL doesn't already do it
            'InvariantCulture',
            'InvariantCultureIgnoreCase',
            'CurrentCulture',
            'CurrentCultureIgnoreCase',
            'Ordinal',
            'OrdinalIgnoreCase'
        )]
        [string]
        $ComparerKind = 'CurrentCultureIgnoreCase',
        # currently does not resolve as a non-string
            # [StringComparer]::CurrentCultureIgnoreCase,



        # normal is to not modify left, return a new hashtable
        [Parameter()][switch]$MutateLeft
    )


        <#
            this works without error
                nin.MergeHash @{ a = 10 } @{ A = 3 } -Comparer CurrentCultureIgnoreCase

            But sometimes, invoke is throwing, which is weird. Shouldn't it be an enum to a string?

               9 |  … mpareType = New-NinStringComparer -PassThru -StringComparerKind $Comp …
                |                ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                | Error creating [StringComparer]::FromComparison( "System.CultureAwareComparer" )

        #>
        # try {
            $newCompareType = New-NinStringComparer -PassThru -StringComparerKind $ComparerKind
        # } catch {
            # $_
#
        # }

        # $newCompareType = [StringComparer]::FromComparison(
        #     [StringComparison]::InvariantCulture )
        # $newCompareType = [StringComparer]::FromComparison( $Comparer )

        # $p2 = [System.StringComparer]::FromComparison( [StringComparison]::InvariantCulture )

        $BaseHash ??= @{}
        $OtherHash ??= @{}

        if (! $MutateLeft ) {
            $TargetHash = [hashtable]::new( $BaseHash, $newCompareType )
        } else {
            Write-Debug 'Mutate enabled'
            $TargetHash = $BaseHash
        }
        $OtherHash.GetEnumerator() | ForEach-Object {
            $TargetHash[ $_.Key ] = $_.Value
        }

        return $TargetHash
}

