#Requires -Version 7.0

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Get-StopWatch'
    )
    $publicToExport.alias += @(
        'stopWatch' # Get-StopWatch
    )
}


$script:__watches = @{} # [Hashtable[Str, StopWatch]]

enum StopWatchAction {
    Get
    GetAndResume
    Resume
    StartNew
    Stop
    StopAndGet
}
function Get-StopWatch {
    <#
    .synopsis
        manages a collection of (Label, [Diagnostics.Stopwatch]) pairs
    .description
        ..
    .example
        PS> stopWatch 'fred' -Debug -ea break StartNew
    .example

        stopWatch -Name 'outside' -Action StartNew
        sleep 0.2
        0..4  | %{
            stopWatch -Name "in_$_" -Action StartNew
            sleep 0.4
            stopWatch -Name "in_$_" -Action StopAndGet
        }
        stopWatch -Name "outside" -Action StopAndGet
    #>
    [Alias(
        # 'Get-StopWatch',
        'stopWatch'
        # 'watch' or 'watchIt' ? or should they enclose a scripblock toio watch
    )]
    [cmdletbinding(DefaultParameterSetName = 'Invoke-Watch')]
    [OutputType('long', $null)]
    param(
        # which ID to act on
        [Alias('Label')]
        [Parameter(ParameterSetName = 'Invoke-Watch', Mandatory, Position = 0)]
        [string]$Name,

        # action type, maps to [stopwatch] methods
        [Alias('Mode')]
        [Parameter(ParameterSetName = 'Invoke-Watch', Mandatory, Position = 1)]
        [StopWatchAction]$Action,
        # [ValidateSet()]
        # [string]$Action,

        # print all watches
        [Parameter(Mandatory, ParameterSetName = 'Get-All')]
        [switch]$GetAll
    )
    # Write-Warning 'validate-working, indirect ref "$Target" or the ??= might be losing state'



    # attempted to see if it worked, [it does]
    # although I do not like default construction of script scope being hidden
    $state = $script:__watches ??= @{} # [Dict[Str, StopWatch]]
    if ($GetAll) {
        return $state
    }
    # better
    # $state = $script:watches
    # $state = $script:watches ??= @{}
    # $state[$Name] ??= [Diagnostics.Stopwatch]::StartNew()
    if (! $State.ContainsKey($Name)) {
        $state[$Name] = [Diagnostics.Stopwatch]::StartNew()
    }
    $Target = $state[$Name]

    # $PSBoundParameters | format-dict | Write-Debug
    $PSBoundParameters | Format-HashTable -Force -LinesBefore 2 | Write-Debug
    Write-Warning "target: $Target"

    switch ($Action) {
        ([StopWatchAction]::StartNew) {
            $target = [Diagnostics.Stopwatch]::StartNew()
            break
        }
        ([StopWatchAction]::Resume) {
            $target.Start()
            break
        }
        ([StopWatchAction]::Stop) {
            $target.Stop()
            break
        }
        ([StopWatchAction]::StopAndGet) {
            $Target.Stop()
            return $Target.ElapsedMilliseconds
        }
        ([StopWatchAction]::Get) {
            return $Target.ElapsedMilliseconds
        }
        ([StopWatchAction]::GetAndResume) {
            $last = $Target.ElapsedMilliseconds
            $target.Start()
            return $last
        }
        default {
            throw "Uhandled: '$Action'"
        }
    }
}
