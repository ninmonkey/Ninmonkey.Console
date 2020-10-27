# $PSDefaultParameterValues["Format-TypeName:WithBrackets"] = $true


function Format-TypeName {
    <#
    .synopsis
        Formats type names to be more readable, removes common prefixes
    .example
        PS> 'System.foo' | AbbrFullName

        PS> $list | %{ $_.GetType().FullName()} | AbbrFullName
    .notes
        todo:
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
            # Todo: the easiest way to get past collisions is to sort this list by length before doing replacements
            # that also removes the hard-coded 'system' removal
            'System.Collections'
            'System.Collections.Generic'
            'System.Text'
            'System.Management.Automation'
            'System.Runtime.CompilerServices'

        ),

        [Parameter(HelpMessage = "Output surrounded with '[]'")]
        [switch]$WithBrackets,

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
        $IgnorePrefix += 'System'
        # Sorting by longest simplifies namespace removal
        $IgnorePrefix = $IgnorePrefix | Sort-Object -Property Length -Descending
    }

    Process {
        # 'arg: {0}' -f ($TypeName ?? $TypeInstance) | Write-Debug
        switch ( $PSCmdlet.ParameterSetName ) {
            'paramTypeAsString' {

                # next: color to summarize ones that still have points
                Write-Debug "String: $TypeName"
                $TypeAsString = $TypeName
                break
            }
            'paramTypeAsInstance' {
                Write-Debug "Instance: $TypeInstance"
                $TypeAsString = $TypeInstance.FullName
                break
            }
            default { throw "not implemented parameter set: $switch" }
        }

        # todo: add paramter to it
        $remappedName = $TypeAsString -replace [regex]::Escape( 'System.Management.Automation.SwitchParameter' ), 'Switch'

        $filteredName = $remappedName
        foreach ($prefix in $IgnorePrefix) {
            $Pattern = '^{0}\.' -f [regex]::Escape( $prefix )
            $filteredName = $filteredName -replace $Pattern, ''
        }
        if (!$WithBrackets) {
            $filteredName
        } else {
            '[', $filteredName, ']' -join ''
        }
    }

}


if ($false -and 'debug sketch to remove') {
    # _FormatCommandInfo-GenericParameterTypeName -Debug -Verbose
    hr 10
    $gcmLs = Get-Command Get-ChildItem
    $inst_paramLs = $gcmLs.Parameters
    $type_paramLs = $gcmLs.Parameters.GetType()

    h1 'Format-TypeName'

    $type_paramLs | Format-TypeName -WithBrackets
    hr

    h1 '.GetType()'
    $inst_paramLs.GetType().FullName
    $type_paramLs
    | Select-Object Name, FullName, Namespace, GenericParameterAttributes, GenericParameterPosition, GenericTypeArguments


    # $gcmLs.Parameters.GetType()

    h1 'FullName | Format-TypeName'
    'cat' | Format-TypeName -WithBrackets
    $type_paramLs | Format-TypeName -WithBrackets

    h1 'type | Format-GenericTypeName'
    $type_paramLs | Format-GenericTypeName -WithBrackets
    hr
    h2 'generic using Format-TypeName'
    $type_paramLs | Format-TypeName -WithBrackets
    Label 'Using Format-GenericTypeName'

    $type_paramLs | Format-GenericTypeName
    hr
    h2 'invoke-RestMethod'

    try {
        Invoke-RestMethod -Uri 'https://httpbin.org/status/500' #|  Out-Null
    } catch {
        $errorRest = $_
        Label 'orig'
        $errorRest, $errorRest.Exception | ForEach-Object { $_.GetType().FullName }
        Label 'FormatTypeName'
        $errorRest, $errorRest.Exception | ForEach-Object {
            $_.GetType()
        } | Format-TypeName -WithBrackets
    }



}