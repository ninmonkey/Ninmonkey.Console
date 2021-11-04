$script:publicToExport.function += @(
    'Get-HelpFromTypeName'
)
$script:publicToExport.alias += @(
    'HelpFromType'
    # 'DevTool💻.Get-HelpFromType'
)

function Get-HelpFromTypeName {
    <#
    .synopsis
        Opens the docs for the current type, in your default browser
    .description
       It uses 'Get-Unique -OnType' so you only get 1 result for duplicated types
    .example
          .
    .outputs
          [string | None]
    .link
        Ninmonkey.Console\Format-TypeName

    #>
    [Alias('HelpFromType')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object]$InputObject,

        # Return urls, without opening them
        [Parameter()]
        [switch]$PassThru
    )

    begin {
        # list of full type nam;es
        $NameList = [list[string]]::new()
        $TemplateUrl = 'https://docs.microsoft.com/en-us/dotnet/api/{0}'
    }
    process {
        if ($InputObject -is 'type') {
            $NameList.Add( $InputObject.FullName )
            return
        }
        if ($InputObject -is 'string') {
            if ( [string]::IsNullOrWhiteSpace($InputObject) ) {
                return
            }

            $typeInfo = $InputObject -as 'type'
            $NameList.Add( $typeInfo.FullName )
            return
        }

        $NameList.Add( $InputObject.GetType().FullName )
    }
    end {
        # '... | Get-Unique -OnType is' great if you want to limit a list to 1 per unique type
        # like 'ls . -recursse | Get-HelpFromTypeName'
        # But I'm using strings, so 'Sort -Unique' works
        $NameList
        | Sort-Object -Unique
        | ForEach-Object {
            $url = $TemplateUrl -f $_

            "Url: '$url' for '$_'" | Write-Debug

            if ($PassThru) {
                $url; return
            }
            Start-Process -path $url
        }
    }
}
