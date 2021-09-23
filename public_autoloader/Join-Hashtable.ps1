$script:publicToExport.function += @(
    'Join-Hashtable'
)
# $script:publicToExport.alias += @(
# 'HelpCommmand')


Function Join-Hashtable {
    <#
    .description
        Copy and append BaseHash with new values from UpdateHash
    .notes
        future: add valuefrom pipeline to $UpdateHash param
    #>
    [cmdletbinding()]
    param(
        # base hashtable
        [Parameter(Mandatory, Position = 0)]
        [hashtable]$BaseHash,
        
        # New values to append and/or overwrite 
        [Parameter(Mandatory, Position = 1)]
        [hashtable]$UpdateHash
    )

    # don't mutate $BaseHash
    $NewHash = [hashtable]::new( $BaseHash )
    $UpdateHash.GetEnumerator() | ForEach-Object {
        $NewHash[ $_.Key ] = $_.Value
    }
    $NewHash
}
