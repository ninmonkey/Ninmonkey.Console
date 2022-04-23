#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Write-NinLogRecord'
    )
    $publicToExport.alias += @(
        'minLog' # ' Write-NinLogRecord'
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
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromPipe')]
    param(
        [Alias('minLog')]
        [Parameter(Mandatory, Position = 0)]
        $Label,

        [Alias('Message', 'Payload')]
        [Parameter(
            ParameterSetName = 'FromPipe',
            Mandatory, ValueFromPipeline)]
        [Parameter(
            ParameterSetName = 'fromParam',
            Mandatory, Position = 1)]
        [object[]]$InputObject,

        # output information stream
        [switch]$PassThru,
        [switch]$JoinAsCsv
    )
    begin {
        throw 'finish me'
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
        $now = ([datetime]::now).ToUniversalTime().ToString('u')
        # $items.ToString()
        $prefix = "${now}: ${Label}: "

        if ($JoinAsString) {
            $render = $Items | Join-String -sep ', ' -op $Prefix #"${Label}: "

        } else {
            $render = $Items | ConvertTo-Json -Depth 9 -EnumsAsString -AsArray
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
