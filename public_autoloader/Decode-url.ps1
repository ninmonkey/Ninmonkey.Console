#using namespace System.Web

if ( $publicToExport ) {
    $publicToExport.function += @(
        'UrlDecode'
    )
    $publicToExport.alias += @(
        'UrlEncode' # alias of 'UrlDecode'
    )
}
# new

# Set-Alias 'UrlEncode' -Value 'UrlDecode' -Description 'It''s one function for now' -ea Ignore
function UrlDecode {
    # [Alias('')]
    [cmdletBinding()]
    param(
        # string to convert
        [string]$url

        # # real
        # [switch]$PassThru
    )
    <#
    .synopsis
        encodes and decodes url strings
    .notes
        a minimal type would remove "format-list" requirement
    #>
    $result = [pscustomobject]@{
        Url     = $url
        Decoded = [Web.HttpUtility]::UrlDecode($url)
        Encoded = [Web.HttpUtility]::UrlEncode($url)
    }

    return $result

}
