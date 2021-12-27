#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Show-XmlPreview'
    )
    $publicToExport.alias += @(
        'ShowXml'
    )
}



function Show-XmlPreview {
    <#
    .synopsis
        simple quick way to preview xml docs, even memory only
    .description
        uses bat for colorizing XML
    .example
        PS> $doc = [xml]'<?xml version="1.0" encoding="utf-8"?> <AssetFile> <Asset> <Role>None</Role> <AssetType>Computing</AssetType> </Asset> </AssetFile>'
        PS> $doc | ShowXml
    .example
        PS> ShowXml 'c:\test.xml'
    #>
    [Alias('ShowXml')]
    param(
        # Either an [XmlDocument] or filepath to one
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [object]$InputObject,

        # Disable color, or 'bat' doesn't exist
        [switch]$NoColor
    )
    begin {
        if ($Env:NO_COLOR) {
            $NoColor = $true
        }
    }
    process {
        # $Options = @{
        #     ShowRelativePath = $false
        # }
        if (Test-Path $InputObject) {
            Write-Debug 'showXml [from file]'

            $DisplayPath = $InputObject | Ninmonkey.Console\ConvertTo-RelativePath
            if ($DisplayPath -match (ReLit '..')) {
                # quick hack, detects that it's not a child
                $DisplayPath = $InputObject

                $DisplayPath = $DisplayPath -replace (Relit (Get-Item Temp:\)), 'Temp:\'
                $DisplayPath = $DisplayPath -replace (relit $Env:LocalAppData), '$Env:LocalAppData'
            }
            if ($NoColor) {
                Get-Content $InputObject
                return
            }

            Get-Content $InputObject | bat -l xml --style 'header,grid' --file-name ($DisplayPath)
            Write-Debug "Should be: $($InputObject) "
            return
        }

        if ($InputObject -is 'System.Xml.XmlDocument') {
            $doc = $InputObject
            Write-Debug 'showXml [in memory]'
            $TempDest = Join-Path (Get-Item temp:) 'render.xml'
            $doc.save( $tempDest ) #| Out-Null
            showXml (Get-Item $TempDest)
            return
        }

    }
}


if (! $publicToExport) {
    # ...
}
