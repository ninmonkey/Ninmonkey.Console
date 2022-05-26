if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'Join-Hashtable'
    )
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
    )

    # don't mutate $BaseHash
    process {
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


