
function Format-TypeName {
    <#
    .synopsis
        Formats type names to be more readable, removes common prefixes
    .example
        PS> 'System.foo' | AbbrFullName

        PS> $list | %{ $_.GetType().FullName()} | AbbrFullName
    .notes
        todo:
            - [ ] a new param, prefixes to substitute
                ex:
                [System.Text.Json] => [t.Json]
            - [ ] support full names that include assemblies. Maybe 'Fullname' itself is not the best option for that.

        notes:

        - colorize: set focus on most important values
        - todo: support pasing of
        - already allows mix of both?
        - param short: uses type Name instead of Fullname (actually do the inverse)
    #>
    param(
        [Parameter(
            ParameterSetName = "paramTypeAsString",
            Mandatory, ValueFromPipeline, HelpMessage = 'list of types as strings')]
        [string]$TypeName,

        [Parameter(
            ParameterSetName = "paramTypeAsInstance",
            ValueFromPipeline, HelpMessage = 'list of types')]
        [System.Reflection.TypeInfo]$TypeInstance,

        [Parameter(
            HelpMessage = "A List of Namespaces or prefixes to ignore")]
        [string[]]$IgnorePrefix = @('System.Text'),

        [Parameter(HelpMessage = "Output surrounded with '[]'")]
        [switch]$WithBrackets

        <#
        todo: need to think at what level I want to intraspect child type
            it should be the function that calls this? Or will typeinfo include that?
        [Parameter(HelpMessage="Print [object[]] verses [object[string]]Output surrounded with '[]'")]
        [switch]$IncludeChild
        #>


    )
    begin {
        $IgnorePrefix += 'System'
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

        $filteredName = $TypeAsString
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
'System.IO.FileInfo' | Format-TypeName -IgnorePrefix 'System.IO'
# exit
$DebugPreference = 'Continue'

$file = (Get-ChildItem . | Select-Object -First 1)
$file.GetType().FullName | Format-TypeName
hr
$file.GetType() | Format-TypeName
$file.GetType() | Format-TypeName -WithBrackets

$DebugPreference = 'SilentlyContinue'

h1 'old tests'
exit


hr 4
$testList = 'b.system.bar', (23).GetType(), 'System.foo', 'System.Object[]', 'foo[]'

& {
    New-Alias AbbrTypeName -Value Format-TypeName -ea Ignore

    foreach ($UseDebug in ($true, $false)) {
        IntToAnsi 0
        h1 "UsingDebug: $UseDebug"

        Label 'default (no args)'
        $testList | Format-TypeName -Debug:$UseDebug
        # (IntToAnsi 0), 'sdfsd' -join ''

        Label '-WithBrackets'
        $testList | AbbrTypeName -WithBrackets -Debug:$UseDebug
        # (IntToAnsi 0), 'sdfsd' -join ''

        hr
        # (IntToAnsi 0), 'sdfsd' -join ''

        Label '-NoBrackets'
        $testList | AbbrTypeName -WithBrackets:$false -Debug:$UseDebug
        # (IntToAnsi 0), 'sdfsd' -join ''
        'bar'
        # hr
        # Label '-IncludeChild'
        # $testList | Format-TypeName -IncludeChild  -Debug:$UseDebug

    }

}

hr 3
Label 'Should Be' 'String'
'dsfds'.GetType().Name | Format-TypeName

Label 'Should Be' '[String]'
'dsfds'.GetType().Name | Format-TypeName -WithBrackets
