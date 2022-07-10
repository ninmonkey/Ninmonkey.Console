# allows script to be ran alone, or, as module import
if (! $DebugInlineToggle ) {
    $experimentToExport.function += @(
        'Where-IsNotBlank'
    )
    $experimentToExport.alias += @(
        '?NotBlank'
    )
}


function Where-IsNotBlank {
    <#
    .synopsis
        a where filter, verses the similar named for asserts: Test-IsNotBlank
    .notes
        filters using [string]::IsNullOrWhiteSpace
        In the future, maybe
            -AllowNull, or
            -AllowEmptyString, or
            -AllowEmptyCollection

        to toggle
        Or even replacing a true-null with "␀"
    .link
        Ninmonkey.Console\Test-IsNotBlank
    .link
        Ninmonkey.Console\Where-IsNotBlank

    .outputs
        [object]
    .link
        Test-IsNotBlank
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '',
        Justification = 'internal experiments, personal REPL')]
    [Alias(
        '?NotBlank'
    )]
    [outputtype([object])]
    [cmdletbinding(PositionalBinding = $false)]
    param(
        # object/strings/collections
        [Parameter(
            position = 0, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        if ( $true -eq [string]::IsNullOrWhiteSpace( $InputObject )  ) {
            return
        }
        $InputObject
    }
}
