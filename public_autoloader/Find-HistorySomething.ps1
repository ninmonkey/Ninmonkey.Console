using namespace System.Collections.Generic
#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        '_showHistory'

    )
    $publicToExport.alias += @(
        # '_showHistory🐒'
    )
}


function _showHistory {
    <#
    .synopsis
        View Highlighted history in a pager
    .notes
    nice filter:
        history |sort -Unique CommandLine | sort id

    types involved:
        [Microsoft.PowerShell.Commands.HistoryInfo]
            - from Get-History
                CommandLine
                Duration
                EndExecutionTime
                ExecutionStatus
                Id
                StartExecutionTime

        [Microsoft.PowerShell.PSConsoleReadLine+HistoryItem]
            - from [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems()
                ApproximateElapsedTime  # often 0
                CommandLine
                FromHistoryFile
                FromOtherSession
                StartTime               # often empty

    #>
    [Alias('_showHistory🐒')]
    [CmdletBinding()]
    param(

        [Alias('State')]
        [Parameter(Position = 0)]
        [Management.Automation.Runspaces.PipelineState]$FilterByState,


        [Parameter(ValueFromPipeline, ParameterSetName = 'FromPipe')]
        [object[]]$InputObject
    )
    begin {
        Write-Warning "finish $PSCommandPath"
        $Template = @{
            Prefix  = "`n`n"
            Suffix  = "`n"
            Command = @'
{-3,0}{3,1:n1}
    {2}
'@
        }
        $Items = [list[object]]::new()
    }
    process {
        if ($Null -eq $InputObject) {
            return
        }
        $Items.AddRange($InputObject)

    }
    end {
        $source = $Items
        # if (! $Items) {
        if (! $Source) {
            Write-Warning 'no source, getting-hist'
            $source = Get-History
        }
        if ($FilterByState) {
            $source = $source
            | Where-Object { $_.ExecutionStatus -eq $FilterByState }
        }

        # Get-History
        # | % CommandLine
        # | Get-Random -Count 3
        $Source
        | Join-String {
            $template.Prefix
            $template.Command -f @(
                $_.Id
                $_.Duration.TotalMilliseconds
                @($_.CommandLine
                    | bat -l ps1 --style=plain --paging=never -f)
                # | Format-IndentText
                # | bat -l ps1
                # | bat -l ps1 --paging=never --color=always
            )
            $template.Suffix
        } -sep ''

        # | str nl 2
        # | bat -l ps1 --plain --paging=auto # to force render, add: -f | echo
    }
}

# Get-History | Select-Object -Last 10
# | _showHistory


# # Get-History | Get-Random -Count 3
# # | _showHistory
