function Find-HelpFromHistory {
    <#
    .example
        Find-HelpFromHistory -StartsWith git
    .notes
        check out the cleanup history functions.
    #>

    [alias('HelpHistory')]
    [CmdletBinding()]
    param (
        # Query
        [Parameter(Mandatory, Position = 0)]
        [string]$StartsWith,

        # Clear the cache
        [Parameter()][switch]$ClearCache
    )
    begin {
        if ($ClearCache) {
            $script:rawText = $Null
        }
        $query = '^' + $StartsWith
        if ([string]::IsNullOrWhiteSpace($script:rawText)) {
            Write-Information 'Loading Cache...'
            Write-Debug 'Loading Cache...'
        }

        $script:rawText ??= $PROFILE.PSReadLineHistoryPath_All
        | ForEach-Object { Get-Content $_ } | Sort-Object -Unique

        $numItems = $script:rawText.count
        $optionsEnabled = @(
            'sort'
            'unique'
        ) | Join-String -sep ', ' -op ' [' -os '] '
        Write-Information "Loaded: $numItems items $optionsEnabled"
        Write-Debug "Loaded: $numItems items $optionsEnabled"
    }
    process {
        Write-Debug "Query: $Query"
        $script:rawText
        | Where-Object { $_ -match $query }
    }

}
