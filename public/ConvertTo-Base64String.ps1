﻿using namespace System.Text



# todo
function ConvertTo-Base64String {
    <#
    .synopsis
        originally from: <Utility\ConvertTo-Base64String>
    .notes
        currently the same, separate same. separate for dependency clarity
    .example
        # For more see:
            <./test/public/ConvertTo-Base64String.tests.ps1>
    .link
        Utility\ConvertTo-Base64String
    #>
    [Alias('Base64')]

    [OutputType([System.String])]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline, Position = 0)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $InputObject,

        [Parameter()]
        [ArgumentCompletions('UTF8', 'ASCII', 'Unicode', 'BigEndianUnicode', 'Default', 'UTF32', 'us-ascii')]
        # [ArgumentCompleter([EncodingArgumentCompleter])]
        [EncodingArgumentConverter()]
        [Encoding] $Encoding
    )
    begin {
        if ($PSBoundParameters.ContainsKey((nameof { $Encoding }))) {
            $userEncoding = $Encoding
            return
        }

        $userEncoding = [System.Text.Encoding]::UTF8
        #used to be: [Encoding]::Unicode # ut8
    }
    process {
        if ([string]::IsNullOrEmpty($InputObject)) {
            return
        }

        return [convert]::ToBase64String($userEncoding.GetBytes($InputObject))
    }
}
