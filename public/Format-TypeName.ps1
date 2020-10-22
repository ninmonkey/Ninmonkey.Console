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


function _FormatCommandInfo-GenericParameterTypeName {
    param(
        [Parameter(
            ParameterSetName = "paramTypeAsInstance",
            ValueFromPipeline,
            HelpMessage = 'list of types')]
        [System.Reflection.TypeInfo]$TypeInstance
    )
    Write-Warning 'this assumes type is a generic'
    hr 2
    $gcmLs = Get-Command Get-ChildItem
    $gcmLs.Parameters.gettype() | Format-TypeName -WithBrackets

    hr
    $gcmLs.Parameters.GetType()
    | Select-Object Name, FullName, Namespace, GenericParameterAttributes, GenericParameterPosition, GenericTypeArguments

    $gcmLs.Parameters.GetType()
    | Select-Object Name, NameSpace, GenericTypeArguments, @{
        Name       = 'GenericType'
        Expression = {
            $_ | Format-TypeName
        }
    }


    <# see also
    IsConstructedGenericType   : True
    IsGenericType              : True
    IsGenericTypeDefinition    : False
    IsGenericParameter         : False
    IsTypeDefinition           : False
#>
    $gcmLs.Parameters.GetType()
    | ForEach-Object {
        $finalName = @(
            $_.Namespace
            $_.Name
        ) -join '.'
        Write-Warning "finalName: $finalName"

        $genericTypeArgList = $gcmLs.Parameters.gettype().GenericTypeArguments
        | ForEach-Object {
            # todo: like above, no full name
            $_.FullName  | Format-TypeName -WithBrackets
        }

        $finalGenericName = @(
            $_.Namespace
            $_.Name
        ) -join '.'
        $finalGenericName += '[wip, bar]'

        Write-Warning "finalGenericName0: $finalGenericName"

        $finalGenericName2 = @(
            $_.Namespace
            $_.Name
        ) -join '.'
        $finalGenericName += ( '[{0}]' -f $genericTypeArgList -join ', ' )

        Write-Warning "finalGenericName1: $finalGenericName"
        Write-Warning "finalGenericName2: $finalGenericName2"

        $finalGenericName3 = '{0}[{1}]' -f @(
            ( $finalGenericName2 | Format-TypeName )
            $genericTypeArgList -join ''
        )

        Write-Warning "finalGenericName3: $finalGenericName3"

        $meta = [ordered]@{
            BaseType         = $_.BaseType | Format-TypeName -WithBrackets
            NameAndSpace     = $_.Namespace, $_.Name -join '.'
            Name             = $_.Name
            NameSpace        = $_.Namespace
            MemberType       = $_.MemberType
            NameSpaceAbbr    = $_.Namespace | Format-TypeName  -WithBrackets
            MemberTypeAbbr   = $_.MemberType | Format-TypeName  -WithBrackets
            CustomAttributes = $_.CustomAttributes
            GenericTypeArgs  = $genericTypeArgList
        }
        $meta['finalName'] = $finalName
        $meta['finalGenericName'] = $finalGenericName3
        [pscustomobject]$meta
    }
    | Format-List


    'System.Collections.Generic' | Format-TypeName -WithBrackets
    | Should -Be '[Generic]'

    Write-Warning "Left off here. trigger when to check for generic names"
}

_FormatCommandInfo-GenericParameterTypeName