#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Write-NinLogRecord'
    )
    $publicToExport.alias += @(
        'ninLog' # ' Write-NinLogRecord'
        'minLog' # ' Write-NinLogRecord'
    )
}

function Set-NinLogOption {
    <#
    .synopsis
        minimal wrapper/entry point to set persistant options
    .link
        Ninmonkey.Console\Set-NinLogOption
    .link
        Ninmonkey.Console\Write-NinLogRecord
    #>
    param(
        # optional
        [Parameter()]
        [string]$LogName = 'ninmonkey.console-shared.log',

        # optional root, names are  relative
        [Parameter()]
        [string]$RootDir = 'H:\data\2022\log_list'
    )
}
function Write-NinLogRecord {
    <#
    .synopsis
        minimal log, One might say ninimal log.
    .description
        Logs datetime with a json payload. (1 json object per line.) Other lines being modified don't break documents.
    .example
        # Find commands From my modules
        > Get-Command
    .synopsis
        # local logging
    .link
        Ninmonkey.Console\Set-NinLogOption
    .link
        Ninmonkey.Console\Write-NinLogRecord
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromPipe')]
    param(
        [Alias(
            'ninLog'
            # 'minLog'
        )]
        [Parameter(Mandatory, Position = 0)]
        $Label,

        # object[s] ppayloadto convertto-Json
        [Alias('Message', 'Payload')]
        [Parameter(ParameterSetName = 'FromPipe', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName = 'fromParam', Mandatory, Position = 1)]
        [object[]]$InputObject,

        # output information stream
        [switch]$PassThru,
        # [switch]$JoinAsCsv

        # kwargs style options
        [Alias('kwargs')]
        [hashtable]$Options = @{}
    )
    begin {
        $Config = @{
            LogPid      = $true
            Time        = @{
                Enabled      = $True
                FormatString = 'u'
                Universal    = $true
            }
            ToJsonSplat = @{
                Depth          = 9
                EnumsAsStrings = $true
                AsArray        = $true
            }
        }
        $Config = Ninmonkey.Console\Join-Hashtable $Config $Options
        throw "finish me $PSCommandPath"
        if (! (Get-Item -ea ignore $AppConf.LLogPath)) {
            New-Item -ItemType File -Path $AppConf.LLogPath -Force
        }

        $log_dest = Get-Item $AppConf.LLogPath
        $items = [list[object]]::new()
    }
    process {
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

        if ($JoinAsString) {
            $render = $Items | Join-String -sep ', ' -op $Prefix #"${Label}: "

        } else {
            $splat = $Config.ToJsonSpat


            $render = $Items | ConvertTo-Json @splat
        }

        $addContentSplat = @{
            Path = $log_dest
        }
        if ($PassThru) {
            $render | Add-Content @addContentSplat -PassThru | Write-Information
            return
        }
        $render | Add-Content @addContentSplat
    }
}
