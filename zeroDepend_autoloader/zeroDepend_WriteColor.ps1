#Requires -Version 7.0

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Write-ConsoleColorZd'
    )
    $publicToExport.alias += @(
        # 'Write-ConsoleColor' # Write-ConsoleColorZd
        # 'Polyfill->WriteColor' # Write-ConsoleColorZd
    )
}
function Write-ConsoleColorZd {
    <#
    .synopsis
        polyfill: Write-ConsoleColor
    .description
        Removes all Dependencies except [Pansies]
    .example
        PS> Set-Alias 'Write-Color' -value 'Write-ConsoleColorZd
        PS> 0..5 | ForEach-Object {
            $_ | _write-color (
                Get-Gradient 'pink' 'blue' | Get-Random -Count 1) }
    .link
        Ninmonkey.Console\Write-ConsoleColor
    #>
    #  polyfill
    [Alias(
        # 'Polyfill->WriteColor',
        # 'Write-ConsoleColor',
        # 'Write-Color'
    )]
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        [Alias('Fg')]
        [Parameter(Mandatory, Position = 0)]
        $Color,

        [Alias('bg')]
        [Parameter()]
        $BackgroundColor
    )
    process {
        $textSplat = @{
            ForegroundColor = $Color
        }
        if ($BackgroundColor) {
            $textSplat['BackgroundColor'] = $BackgroundColor
        }

        $InputObject | Pansies\New-Text @textSplat | ForEach-Object tostring
    }
}
