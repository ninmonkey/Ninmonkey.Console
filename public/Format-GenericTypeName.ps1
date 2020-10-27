# Format-GenericTypeName
Format-GenericTypeName -
function Format-GenericTypeName {
    <#
    .synopsis
        Formats type names🐌 that are generics 🐌
    .description
        foo 🐌
    .example

    .notes
    docs: main reference:
        https://docs.microsoft.com/en-us/dotnet/api/system.reflection.typeinfo?view=netcore-3.1#properties



    see also:
        [remarks: Reflection.TypeInfo](https://docs.microsoft.com/en-us/dotnet/api/system.reflection.typeinfo?view=netcore-3.1#remarks)
        [props: Reflection.TypeInfo](https://docs.microsoft.com/en-us/dotnet/api/system.reflection.typeinfo?view=netcore-3.1#properties)
        [System.Type](https://docs.microsoft.com/en-us/dotnet/api/system.type?view=netcore-3.1#properties)

    #>
    param(
        [Parameter(
            ParameterSetName = "paramTypeAsString",
            Mandatory, ValueFromPipeline,
            HelpMessage = 'Type name as a string:')]
        [string]$TypeName,

        [Parameter(
            ParameterSetName = "paramTypeAsInstance",
            ValueFromPipeline,
            HelpMessage = 'a TypeInfo instance like: $Obj.GetType()')]
        [System.Reflection.TypeInfo]$TypeInstance,

        # [Parameter(
        #     HelpMessage = "A List of Namespaces or prefixes to ignore")]
        # [string[]]$IgnorePrefix = @(
        #     # Todo: the easiest way to get past collisions is to sort this list by length before doing replacements
        #     # that also removes the hard-coded 'system' removal
        #     'System.Collections'
        #     'System.Collections.Generic'
        #     'System.Text'
        #     'System.Management.Automation'
        #     'System.Runtime.CompilerServices'

        # ),

        [Parameter(HelpMessage = "Do not surround with '[]'")]
        [switch]$NoBrackets

        # [Parameter(
        #     HelpMessage = "hash of renaming options")]
        # [hashtable[]]$NameMapping

        <#
        todo: need to think at what level I want to intraspect child type
            it should be the function that calls this? Or will typeinfo include that?
        [Parameter(HelpMessage="Print [object[]] verses [object[string]]Output surrounded with '[]'")]
        [switch]$IncludeChild
        #>
    )


    begin {

    }
    process {
        switch ( $PSCmdlet.ParameterSetName ) {
            'paramTypeAsString' {
                $TypeAsString | Format-TypeName -NoBrackets
                throw "nyi: regex parsing of Generic types from a string"
                # $TypeAsString = $TypeName
                break
            }
            'paramTypeAsInstance' {
                $FormattedTypeName = @(
                    $TypeInstance.Namespace
                    $TypeInstance.Name
                ) -join ''

                $FormattedTypeName = $FormattedTypeName | Format-TypeName -NoBrackets:$NoBrackets

                break
            }
            default { throw "not implemented parameter set: $switch" }
        }

        $PropList = $TypeInstance | Select-Object Name, Namespace, MemberType, *gener*
        | Format-List | Out-String -Width 400
        | Write-Debug

        $FormattedGenericTypeArgs = (
            $TypeInstance.GenericTypeArguments
            | ForEach-Object {
                $_ | Format-TypeName -NoBrackets:$NoBrackets
            }
        ) -join ','

        $FinalTemplate = '[{0}]'

        $FinalTemplate -f (
            $FormattedTypeName, $FormattedGenericTypeArgs -join ''
        )

    }
    end {}
}
