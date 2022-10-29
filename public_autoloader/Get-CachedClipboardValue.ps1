#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Get-CachedClipboardValue'
    )
    $publicToExport.alias += @(
        'CachedClip'  # 'Get-CachedClipboardValue'
    )
}
# new

# Import-Module ClassExplorer
# Import-Module ninmonkey.console -Force
$script:__clipCache ??= @{} # for Get-CachedClipboardValue

function Get-CachedClipboardValue {
    <#
    .synopsis
        sugar for when you're using (get-clipboard) the first time, but don't want it to change
    .EXAMPLE
    PS> #Import-Module Ninmonkey.Console -Force
            cachedClip 'pester1'
            | Set-Content -path 'temp:\cur.ps1' -PassThru

            $PestSrc = gi temp:\cur.ps1
            Invoke-Pester $PestSrc -Output Detailed

        # output:

        PS>
            Running tests from 'C:\Users\cppmo_000\AppData\Local\Temp\cur.ps1'
            Describing d
            [+] My name is: Jakub 6ms (4ms|2ms)
            Tests completed in 72ms
            Tests Passed: 1, Failed: 0, Skipped: 0 NotRun: 0


    #>
    [Alias('cachedClip')]
    [OutputType('System.String', 'System.String[]')]
    [CmdletBinding()]
    param(
        # Key for the cached value
        [Alias('Label')]
        [ValidateNotNull()]
        [Parameter()]
        [string]$KeyName,

        # empty cache
        [Alias('Reset')]
        [switch]$Clear
    )

    $state = $script:__clipCache
    if ($Clear) {
        $state.clear()
    }
    $exists = $state.ContainsKey($KeyName)
    if ([string]::IsNullOrWhiteSpace($KeyName)) {
        throw 'Key is only null or whitespace'
    }

    if ($Exists) {
        Write-Debug 'Key exists'
        return $state.Item($KeyName)
    }
    Write-Debug 'new value'

    $state[$KeyName] ??= Get-Clipboard

    if (-not ($state.ContainsKey($KeyName))) {
        Throw 'ShouldNeverReachException: because of '
    }
    return $state.Item($KeyName)

}

@'
$name = "Jakub"

Describe "d" {
    It "My name is: $name" {
        $name | Should -be "Jakub"
    }
}
'@