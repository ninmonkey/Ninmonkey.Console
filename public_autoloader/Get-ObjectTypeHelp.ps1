#Requires -Version 7
using namespace System.Management.Automation.PSMethod


if ( $publicToExport ) {
    $publicToExport.function += @(
        'Get-ObjectTypeHelp'
    )
    $publicToExport.alias += @(
        'HelpFromType'
    )
}

# 'DevTool💻.Get-HelpFromType'
function Get-ObjectTypeHelp {
    <#
    .synopsis
        Opens the docs for the current type, in your default browser
    .description
       It uses 'Get-Unique -OnType' so you only get 1 result for duplicated types
    .notes
        you can always fallback to the url
            https://docs.microsoft.com/en-us/dotnet/api/
    .example
          .
    .outputs
          [string | None]
    .link
        Ninmonkey.Console\Format-TypeName
    .link
        Ninmonkey.Console\Get-ObjectTypeHelp

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
        # list of full type nam;es1
        $x
        $NameList = [list[string]]::new()
        $TemplateUrl = 'https://docs.microsoft.com/en-us/dotnet/api/{0}'
    }
    process {
        if ( [string]::IsNullOrWhiteSpace($InputObject) ) {
            return
        }
        # if generics cause problems, try another method

        # Management.Automation
        # if ($InputObject -is 'Management.Automation.PSMethod') {
        # todo: refactor to a ProcessTypeInfo -Passthru
        # This function just asks on that
        if ($InputObject -is 'System.Management.Automation.PSMethod') {
            'methods not completed yet' | Write-Host -fore green
            $funcName = $InputObject.Name
            <#
    example state from: [math]::round | HelpFromType
        > $InputObject.TypeNameOfValue

            System.Management.Automation.PSMethod

        > $InputObject.GeTType() | %{ $_.Namespace, $_.Name -join '.'}

            System.Management.Automation.PSMethod`1

        > $InputObject.Name

            Round

    #>
            $maybeFullNameForUrl = $InputObject.GetType().Namespace, $InputObject.Name -join '.'
            # maybe full url:
            @(
                $maybeFullNameForUrl | str prefix 'maybe url' | Write-Color yellow
                $funcName | Write-Color yellow
                $InputObject.TypeNameOfValue | Write-Color orange
                $InputObject.GeTType() | ForEach-Object { $_.Namespace, $_.Name -join '.' } | Write-Color blue
            ) | wi
            $NameList.add($maybeFullNameForUrl)
            return

        }
        if ($InputObject -is 'type') {
            $NameList.Add( $InputObject.FullName )
            $NameList.Add( @(
                    $InputObject.Namespace, $InputObject.Name -join '.'
                ) )
            return
        }
        if ($InputObject -is 'string') {
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




if (! $publicToExport) {
    # [math] | HelpFromType -PassThru
    [math]::Round | HelpFromType -PassThru -infa Continue
}
