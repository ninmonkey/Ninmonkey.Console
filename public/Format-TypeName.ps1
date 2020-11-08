# $PSDefaultParameterValues["Format-TypeName:NoBrackets"] = $true


function Format-TypeName {
    <#
    .synopsis
        Formats type names to be more readable, removes common prefixes
    .example
        PS> 'System.foo' | AbbrFullName

        PS> $list | %{ $_.GetType().FullName()} | AbbrFullName
    .notes
        todo:
            - [ ] if generic call `Format-GenericTypeName`
            - [ ] if not any type, call .GetType() autoatically


            - [ ] include full assembly name etc if wanted
            - [ ] a new param, prefixes to substitute
                ex:
                [System.Text.Json] => [t.Json]
            - [ ] support full names that include assemblies. Maybe 'Fullname' itself is not the best option for that.

        notes:

        - colorize: set focus on most important values
        - todo: support pasing of
        - already allows mix of both?
        - param short: uses type Name instead of Fullname (actually do the inverse)

    see also:
        [ParameterMetadata](https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.parametermetadata?view=powershellsdk-7.0.0)]

        [https://docs.microsoft.com/en-us/dotnet/api/system.reflection.typeinfo?view=netcore-3.1#properties]
    #>
    param(
        [Parameter(
            ParameterSetName = "paramTypeAsString",
            Mandatory, ValueFromPipeline,
            HelpMessage = 'list of types as strings')]
        [string]$TypeName,

        [Parameter(
            ParameterSetName = "paramTypeAsInstance",
            ValueFromPipeline,
            HelpMessage = 'list of types')]
        [System.Reflection.TypeInfo]$TypeInstance,

        [Parameter(
            HelpMessage = "A List of Namespaces or prefixes to ignore")]
        [string[]]$IgnorePrefix = @(
            # the easiest way to get past regex collisions is to sort this list by length before doing replacements
            # that also removes the hard-coded 'system' removal
            'System.Collections'
            'System.Collections.Generic'
            'System.Text'
            'System.Management.Automation'
            'System.Runtime.CompilerServices'

        ),

        [Parameter(HelpMessage = "Output surrounded with '[]'")]
        [Alias('WithoutBrackets')]
        [switch]$NoBrackets,

        [Parameter(
            HelpMessage = "hash of renaming options")]
        [hashtable[]]$NameMapping

        <#
        todo: need to think at what level I want to intraspect child type
            it should be the function that calls this? Or will typeinfo include that?
        [Parameter(HelpMessage="Print [object[]] verses [object[string]]Output surrounded with '[]'")]
        [switch]$IncludeChild
        #>
    )
    begin {
        $DefaultIgnorePrefix = @(
            'System.Collections'
            'System.Collections.Generic'
            'System.Text'
            'System.Management.Automation'
            'System'
        )
        # Sorting by longest regex simplifies namespace collisions when handling  removal
        $IgnorePrefix += $DefaultIgnorePrefix
        $IgnorePrefix = $IgnorePrefix | Sort-Object -Property Length -Descending
    }

    Process {
        # 'arg: {0}' -f ($TypeName ?? $TypeInstance) | Write-Debug
        switch ( $PSCmdlet.ParameterSetName ) {
            'paramTypeAsString' {

                # next: color to summarize ones that still have points
                Write-Debug "Original: $TypeName"
                $TypeAsString = $TypeName
                Write-Verbose 'Nyi: Regex (Format-TypeName)'
                # throw "NYI: get regex: NYI"
                break
            }
            'paramTypeAsInstance' {
                if ($TypeInstance.IsGenericType) {
                    Write-Debug 'IsGenericType: True'
                    $TypeInstance | Format-GenericTypeName -NoBrackets:$NoBrackets
                    return # full exit
                }

                Write-Debug "Instance: $TypeInstance"
                $TypeAsString = $TypeInstance.FullName
                break
            }
            default { throw "not implemented parameter set: $switch" }
        }

        $filteredName = $TypeAsString
        foreach ($prefix in $IgnorePrefix) {
            $Pattern = '^{0}\.' -f [regex]::Escape( $prefix )
            $filteredName = $filteredName -replace $Pattern, ''
            continue
        }
        if ($NoBrackets) {
            $filteredName
        } else {
            '[', $filteredName, ']' -join ''
        }
    }

}
