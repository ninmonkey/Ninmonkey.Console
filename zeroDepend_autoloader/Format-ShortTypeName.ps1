#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Format-ShortTypename'
    )
    $publicToExport.alias += @(
        'shortTypeName' # 'Format-ShortTypename'
    )
}

function Format-ShortTypeName {
    <#
    .EXAMPLE
        PS> [System.Management.Automation.VerboseRecord] | shortTypeName

            [VerboseRecord]
    .example

        PS>
        @( Get-Date; Gi . ;
            [System.Management.Automation.VerboseRecord]
            (gi fg:\)
        ) | ShortTypeName

            [DateTime]
            [IO.DirectoryInfo]
            [VerboseRecord]
            [RgbColorProviderRoot]
    .notes
        render-* implies ansi colors

    .link
        Ninmonkey.Console\Format-ShortTypeName
    .link
        Ninmonkey.Console\Render-ShortTypeName

    #>
    [Alias('shortTypeName')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        if ($InputObject -is 'type') {
            $Target = $InputObject
        } else {
            $Target = $InputObject.GetType()
        }

        $Target.FullName -replace '^System\.(Management.Automation\.)?', '' -replace '^PoshCode\.Pansies', 'Pansies'
        | Join-String -op '[' -os ']'
    }
}
