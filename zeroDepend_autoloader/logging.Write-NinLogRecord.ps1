#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Write-NinLogRecord'
        'Get-NinLogOption'
        'Set-NinLogOption'
    )
    $publicToExport.alias += @(
        # 'ninLog' # ' Write-NinLogRecord'
        'minLog' # ' Write-NinLogRecord' # to make it not collide with future ninlog
        # 'minLog' # ' Write-NinLogRecord'
    )
}

class MinLoggerDestinationConfig {
    # todo: expansion
    # name?
    # [string]$LogName = 'ninmonkey.console-shared'
    # [string]$RootDir = 'H:\data\2022\log_list' # more for the log source?
    [System.IO.FileInfo]$Path

    # [Void] MinLoggerDestination ($x) {

    # }
    # [string]ToString() {
    #     return $this.Path
    # }

}
class MinLoggerConfig {
    # todo: expansion
    # global config
    # [MinLogger]
}

# $logger = [MinLoggerOutConfig]@{
#     LogName = 'ninmonkey.console-shared'
#     RootDir = 'H:\data\2022\log_list'
# }


[hashtable]$script:__ninLog = @{
    LogName = 'min_logger-global'
    RootDir = 'H:\data\2022\log_list'
}
function Get-NinLogOption {

    <#
    .synopsis
        retrieve current config
    .link
        Ninmonkey.Console\Set-NinLogOption
    .link
        Ninmonkey.Console\Get-NinLogOption
    .link
        Ninmonkey.Console\Write-NinLogRecord
    #>
    # todo: use instance of [MinLoggerConfig]
    $state = $script:__ninLog
    return $state
}
function Set-NinLogOption {
    <#
    .synopsis
        minimal wrapper/entry point to set persistant options
    .link
        Ninmonkey.Console\Set-NinLogOption
    .link
        Ninmonkey.Console\Get-NinLogOption
    .link
        Ninmonkey.Console\Write-NinLogRecord
    #>
    param(
        # optional
        [Parameter()]
        [string]$LogName = 'ninmonkey.console-shared',

        # optional root, names are  relative
        [Parameter()]
        [string]$RootDir = 'H:\data\2022\log_list',

        # return new config's state
        [switch]$PassThru
    )

    $state = $script:__ninLog
    $state.LogName = $LogName
    $state.RootDir = $RootDir
    # todo:resolve->PathExists (log)

    if ($PassThru) {
        Get-NinLogOption
        return
    }
    return
}
$splat = @{
    LogName = 'min_logger-global'
    RootDir = 'H:\data\2022\log_list'
}
Set-NinLogOption @splat


function Write-NinLogRecord {
    <#
    .synopsis
        minimal log, One might say ninimal log.
    .description
        only  writes to one log at a time, no context switching or special sublogs yet
        Logs datetime with a json payload. (1 json object per line.) Other lines being modified don't break documents.
    .example
        # Find commands From my modules
        > Get-Command
    .synopsis
        # local logging
    .link
        Ninmonkey.Console\Set-NinLogOption
    .link
        Ninmonkey.Console\get-NinLogOption
    .link
        Ninmonkey.Console\Write-NinLogRecord
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromPipe')]
    param(
        [Alias(
            'ninLog',
            'minLog'
        )]
        [Parameter(Mandatory, Position = 0)]
        $Label,

        # object[s] ppayloadto convertto-Json
        [Alias('Message', 'Payload')]
        [Parameter(ParameterSetName = 'FromPipe', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'fromParam', Mandatory, Position = 1)]
        [object[]]$InputObject,

        # log to information stream: Instead, or in addition?
        [switch]$PassThru,

        # kwargs style options
        [Alias('kwargs')]
        [hashtable]$Options = @{}
    )


    begin {
        [hashtable]$Config = @{
            ShowInConsole = $false # meaning write to outputstream, maybe use -PassThru isntead?
            LogName       = $script:__ninLog.LogName
            LogRootDir    = $script:__ninLog.RootDir
            LogPid        = $true
            Time          = @{
                Enabled      = $True
                FormatString = 'u'
                Universal    = $true
            }
            LogAsString   = $false # meaning no json conversion
            ToJsonSplat   = @{
                Depth          = 9
                EnumsAsStrings = $true
                AsArray        = $true
            }
        }


        $Config = Ninmonkey.Console\Join-Hashtable $Config $Options
        $LogFullName = (Join-Path $Config.LogRootDir $Config.LogName) + '.log'
        if (! (Test-Path $LogFullName )) {
            Write-Verbose "'$LogFullName' did not exist, creating..." #todo:attribute -> creates and logs , replacing this
            New-Item -ItemType File -Path $LogFullName -Force
        }
        $LogFullName = Get-Item $LogFullName
        [list[object]]$items = [list[object]]::new()
    }
    process {
        if ($null -eq $InputObject) {
            return
        }
        if ([string]::IsNullOrEmpty( $InputObject)) {
            # *should* be redundant
            return
        }
        $items.AddRange( $InputObject)
    }
    end {
        $now = [datetime]::Now

        if ( $Config.Time.Universal ) {
            $now = $now.ToUniversalTime()
        }
        $nowStr = $now.ToString( $Config.Time.FormatString )

        # $now = ([datetime]::now).ToUniversalTime().ToString('u')

        # $items.ToString()
        $prefix = @(
            if ($Config.Time.Enabled) {
                "${nowStr}:"
            }
            if ($Config.LogPid) {
                " ${pid}:"
            }
            " ${Label}: "
        ) -join ''

        Write-Debug "prefix: '$Prefix'"

        if ($Config.LogAsString) {
            $render = $Items | Join-String -sep ', ' -op $Prefix #"${Label}: "
        } else {
            $splat = $Config.ToJsonSplat
            $render = $Items | ConvertTo-Json @splat -Compress
        }

        Write-Debug "render: '$render'"
        $finalRender = $prefix, $render -join ''

        $writeLog = @{
            Path = $LogFullName
        }
        if ($PassThru) {
            $finalRender | Add-Content @writeLog -PassThru | Write-Information
            return
        }
        $finalRender | Add-Content @writeLog
    }
}
