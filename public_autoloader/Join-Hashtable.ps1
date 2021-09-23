$script:publicToExport.function += @(
    'Join-Hashtable'
)
# $script:publicToExport.alias += @(
# 'HelpCommmand')

Function Join-Hashtable {
    <#
    .description
        Copy and append BaseHash with new values from UpdateHash
    #>
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory, ValueFromPipeline, Position = 0, HelpMessage = "Base Hashtable")]
        [hashtable]$BaseHash,

        [Parameter(
            Mandatory, Position = 1, HelpMessage = "New values to append and overwrite with")]
        [hashtable]$UpdateHash
    )

    # don't mutate $BaseHash
    $NewHash = [hashtable]::new( $BaseHash )
    $UpdateHash.GetEnumerator() | ForEach-Object {
        $NewHash[ $_.Key ] = $_.Value
    }
    $NewHash
}
