
function Assert-IsNotBlank {
    <#
    .synopsis
        Assert / Test that values are not blank
    .notes
        Blank means
            null, empty strings, or strings containing only whitespace

        future:
            - parameter to allow throwing exceptions else bool
            - test empty collections

    .link
        Ninmonkey.Console\Where-IsNotBlank
    #>
    [cmdletBinding()]

    param(
        [OutputType('System.Boolean')]
        [Alias('!IsNotBlank', 'Test-IsNotBlank')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Alias('Text')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$InputObject,

        # return a boolean instead of throwing
        [switch]$TestOnly
    )
    begin {
        $x = 3
    }

    process {
        $TestIsBlank = [string]::IsNullOrWhiteSpace( $InputObject )
        if ($TestOnly) {
            return $TestIsBlank
        }

        if ( -not $TestIsBlank) {
            return $true
        }

        Write-Error -ea stop -Category InvalidData -Message 'AssertIsNotBlank: value is blank' #  -TargetObject $InputObject
    }
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
        '?IsNotBlank'
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
        if ( [string]::IsNullOrWhiteSpace( $InputObject )  ) {
            return
        }
        $InputObject
    }
}
