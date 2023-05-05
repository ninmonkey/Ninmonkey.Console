#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-NinCachedPipescriptExport' # 'TranspileIfNew.🐒'
    )
    $publicToExport.alias += @(
        'TranspileIfNew.🐒' # 'Invoke-NinCachedPipescriptExport'
        'nin.BuildLazyPipes🐍' # 'Invoke-NinCachedPipescriptExport'

    )

}

function Invoke-NinCachedPipescriptExport {
    <#
    .SYNOPSIS
        basic partial cache to simplfy pipe invoke'
    .NOTES
    .EXAMPLE
        Invoke-NinCachedPipescriptExport -RootPath H:/data/2023/pwsh/PsModules/GitLogger
        | Ft Name, Status, IsStale -AutoSize

    .EXAMPLE
        TranspileIfNew 'H:/data/2023/pwsh/PsModules/GitLogger'
    .EXAMPLE
        TranspileIfNew -RootPath 'H:\data\2023\pwsh\PsModules\GitLogger'  # 1 items
        TranspileIfNew -RootPath 'H:\data\2023\pwsh\PsModules\GitLogger\Azure' # 26 items
    .EXAMPLE
        $query Invoke-NinCachedPipescriptExport -TestOnly -RootPath
        $query | Ft Name, Status, IsStale -AutoSize
        $query | ? IsStale -not
        $query | ? IsStale

        Export-Pipescript -InputPath $query.Source.FullName

    .EXAMPLE
        Export-Pipescript -InputPath @($query | ? IsStale | % Source |% Fullname)



    .LINK
        file:///H:/data/2023/dotfiles.2023/pwsh/vscode/editorServicesScripts/ExportPipescript.ps1
    #>
    [Alias(
        'TranspileIfNew.🐒',
        'nin.BuildLazyPipes🐍'
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
    $Config = @{
        AlwaysIgnoreRootModulesAsSource = $True
    }


    Push-Location '.' -StackName 'pile'
    $InformationPreference = 'continue'
    $Root = Get-Item -ea 'stop' $RootPath
    Push-Location $Root -StackName 'pile'

    $Regex = @{}
    $Regex.IsAPipescriptSource = '(?i)\.ps\.\w+$'
    $Regex.IsAPipescriptRootModule = '(?i)\.ps\.psm1$'
    # $Regex.FindPipescriptExportName = '(?i)\.ps\.\w+$'

    class PipescriptTranspileIfNewRecord {
        <#
        todo:
            - [ ]  make typedata and formatdata, removing the junk
                - [ ] format-wide renders 'baseName <colorIcon>'
            - [ ] cached filenames format as dim gray text for 'name'
            - [ ] stale/new shows as red
        #>
        [String]$Name = [string]::Empty
        [string]$Status = [string]::Empty
        [bool]$IsStale = $true
        [System.IO.FileInfo]$Source
        # [Nullable[System.IO.FileInfo]]$Export
        # [object]$Export?
        [object]$Export
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
    | ForEach-Object {
        $SourceItem = Get-Item $_
        $exportName = $SourceItem.FullName -replace '\.ps\.', '.'
        # $ExportPath = Get-Item -ea 'ignore' $ExportName
        $ExportPath? = Get-Item -ea 'ignore' $ExportName

        if ($SourceItem.FullName -match $Regex.IsAPipescriptRootModule) {
            'skipping module: {0}' -f @(
                $SourceItem.FullName
            ) | Write-Debug
            return
        }

        $record = [PipescriptTranspileIfNewRecord]@{
            Source  = $SourceItem
            Name    = $SourceItem.Name
            Export  = $ExportPath? ?? $null # todo: formatter renders as "␀"
            IsStale = $true
            Status  = 'other'
            # 'Export?' = 'yeah'
        }

        if ( $record.Export -and (Test-Path ($record.Export))) {
            # if($record.Export.LastWriteTime -gt $Source.LastWriteTime) {
            if ($record.Source.LastWriteTime -gt $record.Export.LastWriteTime) {
                $record.IsStale = $true
                $record.Status = '🟡 stale'
            }
            else {
                $record.IsStale = $false
                $record.Status = '🟢 cached'

            }
        }
        else {
            $record.Status = '🔴 missing' # might not exist
            $record.IsStale = $true
        }
        $record





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

    if($TestOnly) { return }

    $query | Where-Object IsStale | ForEach-Object Source | ForEach-Object Fullname | ForEach-Object {
        $_ | Join-String -f 'try: <file:///{0}>' | New-text -fg 'gray45' -bg 'gray20' | Write-information
    }
    write-warning 'left off, would normally build here...'


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

