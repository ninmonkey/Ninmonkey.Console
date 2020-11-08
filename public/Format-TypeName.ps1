function Format-TypeName {
    <#
    .synopsis
        Formats type names to be more readable, removes common prefixes
    .notes

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
        switch ( $PSCmdlet.ParameterSetName ) {
            'paramTypeAsString' {
                Write-Debug "Original: $TypeName"
                $TypeAsString = $TypeName
                Write-Verbose 'Nyi: Regex (Format-TypeName)'
                # throw "NYI: get regex: NYI"
                break
            }
            'paramTypeAsInstance' {
                if ($TypeInstance.IsGenericType) {
                    Write-Debug 'IsGenericType: True'
                    $ShouldBracket = ! $NoBrackets
                    $TypeInstance | Format-GenericTypeName -WithBrackets:$ShouldBracket
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
