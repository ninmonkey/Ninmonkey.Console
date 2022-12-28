#requires -Version 7.0

if ( $publicToExport ) {
    $publicToExport.function += @(
        'FilterBy-MatchesAnyProperty'
    )
    $publicToExport.alias += @(
        # 'experiment.MatchesAnyProp' # is 'FilterBy-MatchesAnyProperty'
        '?AnyPropMatch'                # is 'FilterBy-MatchesAnyProperty'
    )
}

function FilterBy-MatchesAnyProperty {
    <#
    .SYNOPSIS
        check if a pattern matches on one or more properties
    .notes
            to handle -Regex or -LiteralRegex, what is cleaner, handling a parameter alias,
            or, adding another parameter [switch]$UsingRegex
            or inline -Regex (Relit $x)
            [Alias('LiteralRegex')]
        #>
    # sugar for repeated regex tests on different properties
    [Alias(
        # 'FilterBy-MatchesAnyProperty'
        # 'FilterBy-MatchesAnyProperty'
        '?AnyPropMatch',
        'experiment.MatchesAnyProp'
    )]
    # [NinCmdInfo(isExperimental=$true, reason|details='brand new, name will change'] # create attribute
    [CmdletBinding()]
    param(
        # which props to test?
        [Alias('Name')]
        [Parameter(Mandatory)]
        [string[]]$PropertyNames,

        [Alias('Re')]
        [Parameter(Mandatory)]
        [string]$Regex,

        [Parameter(ValueFromPipeline)]
        [object]$InputObject,

        # Test-MatchesAnyProperty should be a proxy instead?
        [Alias('AsBool')]
        [switch]$TestAsBool
    )

    process {
        [bool]$matchedAny = $false

        foreach ($curPropName in $PropertyNames) {
            $isMatching = $InputObject.PSObject.Properties['name'].Value -match $Regex
            $curPropValue = $InputObject.PSObject.Properties['name'].Value
            'Regex: "{0}" isMatching? {1} on property "{2}" with value "{3}"' -f @(
                $Regex
                $isMatching
                $curPropName
                $curPropValue
            )
            | Write-Verbose
            if ($isMatching) {
                $matchedAny = $true
                break
            }

        }
        if ($TestAsBool) {
            return $matchedAny
        }

        # else act as a filter
        if (-not $matchedAny) {
            return
        }
        $InputObject
    }
}