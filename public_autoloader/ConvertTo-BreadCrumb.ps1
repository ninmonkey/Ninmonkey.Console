if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'ConvertTo-BreadCrumb'
    )
    $script:publicToExport.alias += @(
        'ToBread' # 'ConvertTo-BreadCrumb'
        'To->Breadcrumb' # 'ConvertTo-BreadCrumb'
    )
}

function ConvertTo-BreadCrumb {
    [Alias(
        'ToBread',
        'To->Breadcrumb'
    )]
    <#
    .synopsis
        convert paths (real or text) to an array of breadcrumbs . (cross platform)
    .example
        PS> Get-Location | ConvertTo-BreadCrumb

    .example
        # for a custom prompt
        PS> $endingPath =  Get-Location | ConvertTo-BreadCrumb
            | Select -Last 3
            | Join-String -sep ' / '


        function Prompt {
            $Path = New-Text $EndingPath -fg '#515C6B'
            $promptText = @(
                $Path
                🐒>
            ) -join "`n"

            $promptText
        }


    #>
    param(
        # can be a path, string, path separators work either wayBath can be
        [Alias('PSPath', 'Path')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [string]$InputObject
    )
    begin {
        $IOSepLiteral = [Regex]::Escape( [IO.Path]::DirectorySeparatorChar )
    }

    process {
        # There's probably a dotnet function that would 'normalize filepath' and delimiters

        if ($InputObject -match '\\\\') {
            $delim = [regex]::escape( '\\')
        } elseif ($InputObject -match '\\') {
            $delim = [regex]::escape('\')
        } elseif ($InputObject -match '/' ) {
            $delim = '/'
        } elseif ($InputObject -match $IOSepLiteral ) {
            $delim = $IOSepLiteral
        } else {
            Write-Error -Message 'Could not determine path separator' -TargetObject $InputObject -Category 'InvalidData'
            return
        }
        # Wait-Debugger
        $crumbs = $InputObject -split $delim
        if ($crumbs.Count -le 0) {
            Write-Error "Length of 0 using '$InputObject'" -Category InvalidResult -TargetObject $InputObject
        }
        $crumbs
    }

}
