using namespace System.Collections.Generic

#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        '_randPath'
    )
    $publicToExport.alias += @(
        '_randGC' # 'Get-SequentialRandomLines '
        'Rand->GCChunks' # 'Get-SequentialRandomLines '
        'Rand->Path' # '_randPath'
    )
    # $publicToExport.variable += @(

    # )
}


function _randPath {
    <#
    .synopsis
        Sugar for random folders
    .example
        PS> _randPath | Goto
    #>
    [Alias('Rand->Path')]
    [OutputType('System.IO.DirectoryInfo')]
    param(
        [string]$PathRoot = '~',
        [int]$Depth = 2,
        [int]$Count = 1
    )
    $getChildItemSplat = @{
        Depth     = $Depth
        Directory = $true
        Path      = $PathRoot
    }

    Get-ChildItem @getChildItemSplat | Get-Random -Count $Count
}

function Get-SequentialRandomLines {
    <#
    .synopsis
        grab chunks from random offsets from a file,
    .description
        Probably insanely slow, super naive read lines
    .example
        PS> Get-SequentialRandomLines -InputLine <text>
    .example
        PS> gc hiword.txt | Get-SequentialRandomLines

            345 ..
            346 ..
            347 ..

    .NOTES
        started with something in the cli:

            $fPath = '.\trace_stripAnyCommand.log'
            $TotalLInes = (Get-Content .\trace_stripAnyCommand.log | Measure-Object -Line).lines
            #$randSequentialChunks = $TotalLines

            $OffsetList = Get-Random -Minimum 0 -Maximum ($TotalLines)
            $curOffset = $OffsetList
            Get-Content $fpath | Select-Object -Index ($OffsetList..($OffsetList + 5))

    .link
        Ninmonkey.Console\_randWord
    #>
    [Alias('_randGC', 'Rand->GCChunks')]
    [CmdletBinding(DefaultParameterSetName = 'FromPipe')]
    param(
        # raw text, as pipe or param
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromPipe')]
        [string[]]$InputLine,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromFile')]
        [object[]]$Filename
    )
    begin {
        $Config = @{
            LinesPerChunk  = 3
            NumberOfChunks = 2
        }
        [List[string]]$items = [list[string]]::new()
        switch ($PSCmdlet.ParameterSetName) {
            'FromPipe' {
                break
            }
            default {
                throw "Unhandled ParameterSet: $($PSCmdlet.ParameterSetName), $_"
            }
        }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'FromPipe' {
                $items.AddRange( $InputLine )
                break
            }
            default {
                throw "Unhandled ParameterSet: $($PSCmdlet.ParameterSetName), $_"
            }
        }
    }
    end {
        switch ($PSCmdlet.ParameterSetName) {
            'FromPipe' {
                $items.AddRange( $InputLine )
                break
            }
            default {
                if ($false -and $originalhack) {
                    $fPath = '.\trace_stripAnyCommand.log'
                    $TotalLInes = (Get-Content .\trace_stripAnyCommand.log | Measure-Object -Line).lines
                    #$randSequentialChunks = $TotalLines

                    $OffsetList = Get-Random -Minimum 0 -Mgaximum ($TotalLines)
                    $curOffset = $OffsetList
                    Get-Content $fpath | Select-Object -Index ($OffsetList..($OffsetList + 5))
                }
                throw "Unhandled ParameterSet: $($PSCmdlet.ParameterSetName), $_"
            }
        }

        Write-Warning 'something is brok for parameter set'

        $TotalLines = $items.Count
        $OffsetList = @(
            Get-Random -Minimum 0 -Maximum ($TotalLines - 1 ) -Count $Config.NumberOfChunks
        )
        foreach ($offset in $OffsetList) {
            Write-Debug "$offset"

            # Get-Content $fpath
            $items
            | Select-Object -Index ($OffsetList..($OffsetList + $Config.LinesPerChunk))
            # Unable to cast object of type 'System.Object[]' to type 'System.IConvertible'.
        }

    }
}
