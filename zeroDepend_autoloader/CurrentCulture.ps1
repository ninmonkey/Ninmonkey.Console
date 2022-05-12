#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Set-CurrentCulture'
        'Get-CurrentCulture'
    )
    $publicToExport.alias += @(
        '_setCurrentCulture'
        '_getCurrentCulture'

    )
}

function Set-CurrentCulture {
    <#
    .notes
        see SO link for the best summary of what, where, and when will
        string operations use the invariant culture or not

        Older methods required a hack, changing culture using another thread,
        this is no longer required.
    .link
        Get-CurrentCulture
    .link
        Set-CurrentCulture
    .link
        https://stackoverflow.com/a/37603732/341744
    #>
    # mostly to document what's involved
    [Alias('_setCurrentCulture')]
    [OutputType('System.Void', 'Globalization.CultureInfo')]
    param(
        # string or instance
        [ArgumentCompletions('en-US', 'en-GB', 'de-DE', 'fr-fr')]
        [object]$CultureInfo,
        [switch]$PassThru
    )
    [cultureinfo]::CurrentCulture = $CultureInfo #'de-DE'
    if ($PassThru) {
        return Ninmonkey.Console\_getCulture
    }
}
function Get-CurrentCulture {
    <#
    .link
        Get-CurrentCulture
    .link
        Set-CurrentCulture
    .link
        https://stackoverflow.com/a/37603732/341744
    #>
    [OutputType('Globalization.CultureInfo')]
    # mostly to document what's involved
    [Alias('_getCurrentCulture')]
    param()
    return [cultureinfo]::CurrentCulture
}
