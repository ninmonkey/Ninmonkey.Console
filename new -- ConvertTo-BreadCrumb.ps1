function ConvertTo-BreadCrumb {
    [Alias('ToBread')]
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
    param( [string]$filepath )

    $delim = [Regex]::Escape( [IO.Path]::DirectorySeparatorChar )
    ( Get-Location ) -split $delim

}

