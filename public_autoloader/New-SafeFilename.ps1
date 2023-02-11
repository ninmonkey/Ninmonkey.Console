#Requires -Version 7



if ( $publicToExport ) {
    $publicToExport.function += @(
        'New-SafeFileTime'
    )
    $publicToExport.alias += @(
        'nin.Filetime' # 'New-SafeFileTime'
    )
}


function New-SafeFileTime {
    <#
    .SYNOPSIS
        Create safe filnames by using the time in seconds: "2022-08-17_12-46-47Z"
    .notes
        Templates to simplify filenames
    .example
        > New-SafeFileTime

            2023-02-11_12-38-35Z
    .example
        > New-SafeFileTime -TemplateString 'AutoExport-{0}.xlsx'
        > New-SafeFileTime -TemplateString 'AutoExport-{0}.xlsx'

            AutoExport-2023-02-11_12-37-45Z.xlsx
            AutoExport-2023-02-11_12-38-18Z.xlsx

    #>
    [Alias('nin.Filetime')]
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [ArgumentCompletions(
            "'{0}'",
            "'AutoExport-{0}.xlsx'",
            "'Logger-{0}.log'"
        )]
        [string]$TemplateString = '{0}',

        # to add ms/ns later
        [Parameter(Position = 1)]
        [ValidateSet('Seconds')]
        [string]$Precision = 'Seconds'
    )
    $render = $TemplateString -f @(
        (Get-Date).ToString('u') -replace '\s+', '_' -replace ':', '-'
    )
    'New-SafeFileTime generated: "{0}"' -f @( $Render )
    | Write-Verbose
    $render
}