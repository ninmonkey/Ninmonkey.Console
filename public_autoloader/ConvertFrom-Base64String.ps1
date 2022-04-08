#Requires -Version 7
using namespace System.Text

$script:publicToExport.function += @(
    'ConvertFrom-Base64String'
)
$script:publicToExport.alias += @(
    'From->Base64'
)



# todo
function ConvertFrom-Base64String {
    <#
    .synopsis
        originally from: <Utility\ConvertFrom-Base64String>
    .notes
        currently the same, separate same. separate for dependency clarity
    .example
        # For more see:
            <./test/public/ConvertFrom-Base64String.tests.ps1>
    .link
        Utility\ConvertFrom-Base64String
    #>
    [Alias('From->Base64')]
    [OutputType([System.String])]
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

        Write-Warning "finish function: '$PSCommandPath' "
        $decoded_bytes = [convert]::FromBase64String($InputObject)
        return $userEncoding.GetString( $decoded_bytes )
        return

        # see: $userEncoding.GetString | fm * -Force | Get-Parameter -ea Ignore | ft -AutoSize

        $byteStr = [convert]::FromBase64String($b64)
        [System.Text.UTF8Encoding]::UTF8.GetString( $byteStr )
        $userEncoding.GetString(
            <# bytes: #> $byteStr)

        $userEncoding.GetString(
            $InputObject
        )

        Write-Warning "finish function: '$PSCommandPath' "
        return
        return [convert]::ToBase64String($userEncoding.GetBytes($InputObject))
    }
}
