﻿using namespace System.Collections.Generic
# Format-GenericTypeName

function Format-GenericTypeName {
    <#
    .synopsis
        Formats type names that are generics
    .description

    .example
        PS> $items.GetType().FullName
        System.Collections.Generic.List`1[[System.Object, System.Private.CoreLib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]

    .notes
    docs:
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

        [Parameter(HelpMessage = "surround the outter most with brackets")]
        [switch]$WithBrackets
    )

    begin {

    }
    process {
        switch ( $PSCmdlet.ParameterSetName ) {
            'paramTypeAsString' {
                $TypeAsString | Format-TypeName -NoBrackets
                throw "nyi: regex parsing of Generic types from a string"
                break
            }
            'paramTypeAsInstance' {
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

        $InnerList = $TypeInstance.GenericTypeArguments | ForEach-Object {
            $n = $_.Namespace, $_.Name -join '.'
            $n | Format-TypeName -NoBrackets:$false
        }
        $InnerList | Write-Debug

        $FormattedGenericTypeArgs = $InnerList -join ', '
        $FinalTemplate = '{0}'
        $FinalTemplate -f (
            $FormattedTypeName, "[${FormattedGenericTypeArgs}]" -join ''
        )
    }
    end {}
}
