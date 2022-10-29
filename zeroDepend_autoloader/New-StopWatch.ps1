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
    Remove
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
    .example
        
        Pwsh> stopWatch -GetAll | %{ $_.psobject.properties | s name -exp value } | Ft

            Name    IsRunning Elapsed          ElapsedMilliseconds ElapsedTicks
            ----    --------- -------          ------------------- ------------
            in_3        False 00:00:00.4193357                 419      4193357
            in_2        False 00:00:00.4167248                 416      4167248
            in_0        False 00:00:00.4102604                 410      4102604
            outside     False 00:00:02.3053855                2305     23053855
            in_4        False 00:00:00.4120919                 412      4120919
            no-op       False 00:00:00.3524748                 352      3524748
            in_1        False 00:00:00.4124001                 412      4124001
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
        [switch]$GetAll,

        # ansi colors
        [Parameter()][switch]$Fancy
    )
    # Write-Warning 'validate-working, indirect ref "$Target" or the ??= might be losing state'



    # attempted to see if it worked, [it does]
    # although I do not like default construction of script scope being hidden
    $state = $script:__watches ??= @{} # [Dict[Str, StopWatch]]
    if ($GetAll) {
        if(-not $fancy) {
            return [pscustomobject]$state
        }
            $state.GetEnumerator()  | Sort-Object { $_.Key }
             | %{
                $_.Value.elapsed.TotalMilliSeconds | label $_.Key }        
        return
    }
    # better
    # $state = $script:watches
    # $state = $script:watches ??= @{}
    # $state[$Name] ??= [Diagnostics.Stopwatch]::StartNew()
    if (! $State.ContainsKey($Name)) {
        $state[$Name] = [Diagnostics.Stopwatch]::StartNew()
    } else {
        $Target = $state[$Name]
    }

    # $PSBoundParameters | format-dict | Write-Debug
    $PSBoundParameters | Format-HashTable -Force -LinesBefore 2 | Write-Debug
    

    switch ($Action) {
        ([StopWatchAction]::StartNew) {
            $target = [Diagnostics.Stopwatch]::StartNew()
            break
        }
        ([StopWatchAction]::Resume) {
            $target.Start()
            break
        }
        ([StopWatchAction]::Remove) {
            if($Name) { $state.Remove( $Name )  }
            else { $state.Clear() }
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
