#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Enable-NinHistoryHandler'
        'Get-NinHistoryHandlerLog'

    )
    $publicToExport.alias += @(

    )
}


$script:__historyhandler = @{
    Path = Join-Path $Env:UserProfile '.ninmonkey/raw_history.jsonl'
}

function Get-NinHistoryHandlerLog {
    [CmdletBinding()]
    param()

    $LogPath = $script:__historyHandler.Path
    if (! (Test-Path $LogPath)) {
        throw "Log was not found in the defaut location: '$LogPath'"
    }
    $Log = Get-Item $Logpath
    $dbg = @{
        SizeMb = $Log.Length / 1mb | ForEach-Object tostring 'n2'
        Lines  = Get-Content $log | Measure-Object -Line | ForEach-Object Line
    }
    $dbg | Format-Table | Out-String | Write-Debug
    return $Log
}
function Enable-NinHistoryHandler {
    <#
    .SYNOPSIS
        autosave paths for future completions
    #>
    $LogPath = $script:__historyHandler.Path
    Write-warning "Enable-NinHistoryHandler: adding PSReadLine AddToHistoryHandler '$LogPath'"
    Set-PSReadLineOption -AddToHistoryHandler {
        <#
        .synopsis
            spartan method to track history
        #>
        param([string]$line)

        $trigger = '^' + ('goto|cd|set-location|push-location')

        $LogPath = $script:__historyHandler.Path
        if (! (Test-Path $LogPath)) {
            New-Item -ItemType File -Path $LogPath
        }
        $Log = Get-Item $LogPath
        if ($Log.Length -gt 5mb) {
            Write-Warning "LogMaxSizeLimitException: '$Log', rotating (source: $($PSCommandPath))"
            write-warning 'rotate to safe time filename'
            $rotateDest = $Log.FullName -replace '\.log^', '.0.log' # should use file time
            $log | Move-Item -dest "$($log.FullName).0.log"
            Write-Warning "rotated log -> $($log.FullName).0.log"
            Clear-content $Log -ea ignore
            return
        }

        if ($Line -match $trigger) {
            @{
                When        = (Get-Date).tostring('u')
                Pid         = $pid
                ParentPid   = (Get-Process -Id $pid).Parent.Id
                FullCommand = $Line
            }
            | ConvertTo-Json -Compress
            | Add-Content -Path (Get-Item $LogPath)
        }

        return $line
        # return ($line -notmatch $sensitive)
    }
}
