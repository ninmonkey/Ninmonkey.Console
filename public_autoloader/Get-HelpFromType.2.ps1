if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'Get-HelpFromType'
    )
    $script:publicToExport.alias += @(
        'HelpFromType' # 'Get-HelpFromType2'
    )
}

function Get-HelpFromType {

    [Alias('HelpFromType')]
    [CmdletBinding()]
    param(
        # Types to inspect
        [Parameter(ValueFromPipeline, Mandatory)]
        [object[]]$InputObject,

        # skip opening the browser
        [switch]$TestOnly
    )
    begin {
        # strongly typing
        [List[object]]$items = @()
    }
    process {
        $InputObject | ForEach-Object { $items.add(
                $_.GetType()
            ) }
    }
    end {
        $uniques = $items | Get-Unique -OnType
        $meta = @{
            NumberOfTypes = $items.count
            UniqueTypes   = $uniques.count
            ShortNames    = $uniques | shortType
        }

        $meta
        | Format-HashTable -FormatMode Pair
        | Write-Information

        $uniques | ForEach-Object {
            $url = 'https://docs.microsoft.com/en-us/dotnet/api/{0}' -f @(
                $_.FullName
            )
            $url
            | Join-String -op 'url: ' -SingleQuote
            | Write-Information

            if (-not $TestOnly) {
                Start-Process $Url
            }
        }
    }
}
if ($false) {
    # Hr 3
    $foundTypes = Get-ChildItem .. -Depth 2 | Select-Object -First 20
    | Get-HelpFromType -TestOnly -infa 'continue'

    Get-Process
    | Get-HelpFromType -TestOnly -infa 'continue'
}