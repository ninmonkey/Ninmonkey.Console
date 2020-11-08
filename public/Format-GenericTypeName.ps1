# Format-GenericTypeName

function Format-GenericTypeName {
    <#
    .synopsis
        Formats type names🐌 that are generics 🐌
    .description
        foo 🐌
    .example
        PS>
        PS> $items.GetType().FullName
        System.Collections.Generic.List`1[[System.Object, System.Private.CoreLib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]

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
                # $FormattedTypeName = @(
                #     $TypeInstance.Namespace
                #     $TypeInstance.Name
                # ) -join ''

                # $FormattedTypeName = $FormattedTypeName | Format-TypeName -NoBrackets:$true
                $FormattedTypeName = $TypeInstance.Namespace, $TypeInstance.Name -join '.'
                | Format-TypeName -WithoutBrackets

                break
            }
            default { throw "not implemented parameter set: $switch" }
        }
        "Original: $($TypeInstance.FullName)"
        | Write-Debug
        'Original: {0}' -f ( $TypeInstance.Namespace, $TypeInstance.Name -join '.')
        | Write-Debug

        $PropList = $TypeInstance | Select-Object Name, Namespace, MemberType, *gener*
        | Format-List | Out-String -Width 400
        | Write-Debug

        # $FormattedGenericTypeArgs = (
        #     $TypeInstance.GenericTypeArguments
        #     | ForEach-Object {
        #         $genericArg = $_
        #         # maybe this is it
        #         # $_ | Format-TypeName -NoBrackets:$NoBrackets
        #         $FormattedTypeName = ($genericArg.Namespace, $genericArg.Name -join '.')
        #         | Format-TypeName -WithoutBrackets
        #     }
        # ) -join ','

        $InnerList = $TypeInstance.GenericTypeArguments | ForEach-Object {
            $n = $_.Namespace, $_.Name -join '.'
            $n | Format-TypeName -NoBrackets:$false
        }
        $InnerList | Write-Debug

        $FormattedGenericTypeArgs = $InnerList -join ', '

        # $FinalTemplate = '[{0}]'
        if ($NoBrackets) {
            $FinalTemplate = '{0}'
        } else {
            $FinalTemplate = '[{0}]'
        }

        $FinalTemplate -f (
            $FormattedTypeName, $FormattedGenericTypeArgs -join ''
        )

    }
    end {}
}


$objParam = (Get-Command -Name 'Get-ChildItem').Parameters
$TInfo = $objParam.GetType()

$TInfo | Format-GenericTypeName -Debug -NoBrackets
hr
$TInfo | Format-GenericTypeName -NoBrackets:$true
$TInfo | Format-GenericTypeName -NoBrackets:$false
Label 'default'
$TInfo | Format-GenericTypeName
Label 'orignal'
$TInfo.FullName


if ($false) {
    $useDebug = $false

    h1 'format type-name wip'
    ($TInfo.Namespace, $TInfo.Name) -join '' | Format-TypeName -Debug


    $useDebug = $false
    h1 'format generic name wip wip'
    $TInfo | Format-GenericTypeName -Debug:$useDebug
    hr
    $TInfo | Format-GenericTypeName -Debug:$useDebug -NoBrackets
}