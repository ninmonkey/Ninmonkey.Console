#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-NinCachedPipescriptExport' # 'TranspileIfNew.🐒'
    )
    $publicToExport.alias += @(
        'TranspileIfNew.🐒' # 'Invoke-NinCachedPipescriptExport'

    )

}

function Invoke-NinCachedPipescriptExport {
    <#
    .SYNOPSIS
        basic partial cache to simplfy pipe invoke'
    .NOTES
    .EXAMPLE
        TranspileIfNew 'H:/data/2023/pwsh/PsModules/GitLogger'
    .EXAMPLE
        TranspileIfNew -RootPath 'H:\data\2023\pwsh\PsModules\GitLogger'  # 1 items
        TranspileIfNew -RootPath 'H:\data\2023\pwsh\PsModules\GitLogger\Azure' # 26 items
    .LINK
        file:///H:/data/2023/dotfiles.2023/pwsh/vscode/editorServicesScripts/ExportPipescript.ps1
    #>
    [Alias(
        'TranspileIfNew.🐒'
    )]
    [OutputType('[object[]]', '[PipescriptTranspileIfNewRecord[]]')]
    [CmdletBinding()]
    param(
        [ArgumentCompletions(
            # future: argcompleter with history
            # it suggests paths but sorts them by previous frecency
            # the completer takes keyword args to control it
            'H:/data/2023/pwsh/PsModules/GitLogger/Commands',
            'H:/data/2023/pwsh/PsModules/GitLogger/Azure',
            'H:/data/2023/pwsh/PsModules/GitLogger/docs',
            'H:/data/2023/pwsh/PsModules/GitLogger',
            'H:/data/2023/pwsh/notebooks'
        )]
        [Alias('Base', 'Path')]
        [Parameter()]

        [string]$RootPath = 'H:/data/2023/pwsh/PsModules/GitLogger/Azure',

        [Alias('PassThru')]
        [switch]$TestOnly
    )
    Push-Location '.' -StackName 'pile'
    $InformationPreference = 'continue'
    $Root = Get-Item -ea 'stop' $RootPath
    Push-Location $Root -StackName 'pile'

    $Regex = @{}
    $Regex.IsAPipescriptSource = '(?i)\.ps\.\w+$'
    # $Regex.FindPipescriptExportName = '(?i)\.ps\.\w+$'

    class PipescriptTranspileIfNewRecord {
        [System.IO.FileInfo]$Source
        [System.IO.FileInfo]$Export
        [bool]$IsStale = $true
        [string]$Status

    }

    # Get-Item . | Write-Verbose

    $Root
    | Join-String -f "=> ${fg:gray40}${bg:gray30}{0}$($PSStyle.Reset)"
    | Write-Information

    [Collections.Generic.List[Object]]$query = @(
        Get-ChildItem -Path $Root -Recurse -File
        | Where-Object name -Match $Regex.IsAPipescriptSource
        | CountOf
    )

    # $query | ForEach-Object FullName | ForEach-Object { $_ -replace '\.ps\.', '.' }
    $query
    | % {
        $Source = $_
        $exportName = $Source.FullName -replace '\.ps\.', '.'
        # $ExportPath = Get-Item -ea 'ignore' $ExportName
        $ExportPath = $ExportName

        $record = [PipescriptTranspileIfNewRecord]@{
            Source = Get-Item $Source
            ExportPath = $ExportPath
            IsStale = $true
            Status = 'other'
        }

        if( test-path $record.ExportPath) {
            if($record.ExportPath.LastWriteTime -gt $Source.LastWriteTime) {
                $record.IsStale = $false
                $record.Status = '🟢 cached'
            } else {
                $record.IsStale = $true
                $record.Status = '🟡 stale'

            }
        } else {
            $record.Status = '🔴 unknown'
        }
        return $record





        # if(-not $ExportPath) {
        #     '🔴 unknown: {0}' -f @(
        #         $Source
        #     ) | write-host
        #     return $false
        # }

        # if($ExportPath.LastWriteTime -lt $Source.LastWriteTime) {
        #     '🟢 newer: {0}' -f @(
        #         $Source
        #     ) | write-host
        #     return $true

        # } else {
        #     '🟡 cached: {0}' -f @(
        #         $Source
        #     ) | write-host
        #     return $false

        # }


    }

    # $all = gci $Root

    # $all | ?{ $_.Name -match '\.ps\.' }

    Pop-Location -StackName 'pile'
    Pop-Location -StackName 'pile'

}

# TranspileIfNew 'H:/data/2023/pwsh/PsModules/GitLogger/Azure'

# throw 'left off here'
# filter by query pop
<#
this is now command 'nin.Where-FilterByGroupChoice'
{
    $origCommand = Get-Command '*pipe*'
    $GroupOnSBOrName = 'source'
    $FzfTitle = 'choose items to filter $OrigCommand: Gcm "*pipe*"'

    $GroupByChoices = $origCommand
    | Group-Object $GroupOnSBOrName -NoElement
    | ForEach-Object Name | Sort-Object -Unique
    | ?{ $_ }

    # $selectedChoices =
    $What = $GroupByChoices
#
    | & fzf '--layout=reverse' '-m'

    gcm '*pipe*' | ?{ $_.$GroupOnSBOrName -in $what }

}
#>

