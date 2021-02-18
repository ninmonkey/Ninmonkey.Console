


function ConvertTo-Base64String {
    <#
    .synopsis
        originally from: <ConvertTo-SciBase64String>
    .notes
        currently the same, separate same. separate for dependency clarity
    .example
        # For more see:
            <./test/public/ConvertTo-Base64String.tests.ps1>
    #>
    [Alias('Base64')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline, Position = 0)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $InputObject,

        [Parameter()]
        [ArgumentCompleter([EncodingArgumentCompleter])]
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
