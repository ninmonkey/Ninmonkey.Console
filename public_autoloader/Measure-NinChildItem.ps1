using namespace Management.Automation

$script:publicToExport.function += @(
    'Measure-NinChildItem'
)
$script:publicToExport.alias += @(
    'measureLs'
    'CliTool💻-Measure-NinChildItem'
)

function Measure-NinChildItem {
    <#
    .synopsis
        Console/Minimal wrapper for Measure-ChildItem
    .description
        PS> Measure-ChildItem
    .description
        PS> Measure-ChildItem -path '.'
    .example
        🐒> ls . -Directory | measureLs | sort Bytes -Descend

            RelativePath         SizeStr FileCount DirectoryCount
            ------------         ------- --------- --------------
            .\dotfiles_ancient   1 GB         1317            677
            .\Power BI           766 MB      22881           5143
            .\dotfiles           461 MB      16411            104
            .\work               416 MB       4168            886
            .\Powershell         148 MB       7903           2669
            .\Python             44 MB        4390            581
            .\My_Github          38 MB         655            271
            .\dotfiles_git       7 MB         1600            375

    .notes
        create a
        # todo: Update-TYpeData 'Nin.Diskusage'

        🐒> $x = Measure-ChildItem;
        🐒> $x | iprop

            Name           TypeNameStr ValueStr
            ----           ----------- --------
            Path           [String]    G:\2021-github-downloads
            Size           [Double]    9352828
            FileCount      [UInt64]    2835
            DirectoryCount [UInt64]    286

    .outputs
        [Nin.Nin.DiskUsageSummary[]]
    #>
    [alias('measureLs', 'CliTool💻-Measure-NinChildItem')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Alias('Path')]
        [Parameter(Position = 0, ValueFromPipeline)]
        [string[]]$InputPath = '.'
    )
    process {
        $InputPath | ForEach-Object { # -ea continue {
            $curPath = $_
            if (!(Test-Path $curPath) -or !(Test-IsDirectory $curPath)) {
                # $errorRecord = [ErrorRecord]::
                # $PSCmdlet.WriteError(
                #     <# ErrorRecord: #> $errorRecord)
                Write-Error "'Invalid Path: $curPath'" -TargetObject $curPath #@-Exception

                return
            }
            # $bytes = Measure-ChildItem -Path $curPath -Unit B -ValueOnly
            $query = Measure-ChildItem -Path $curPath -Unit B #-ValueOnly
            $summaryObj = [pscustomobject]@{
                'PSTypeName'     = 'Nin.DiskUsageSummary'
                'Path'           = Get-Item $query.'Path'
                'Bytes'          = [Int64]$query.'Size'
                'SizeStr'        = $query.'Size' | Format-FileSize # convert to dynamic value ?
                # 'SizeStr'        = ($query.'Size' | Format-FileSize).PadLeft(20) # convert to dynamic value ?
                # 'Size'           = [int64]$query.'Size'
                'FileCount'      = $query.'FileCount'
                'DirectoryCount' = $query.'DirectoryCount'
            } 
            $summaryObj
            
            
        }
    }
}

$splatForceIgnore = @{ Force = $true; 'Ea' = 'Ignore' }


Update-TypeData -TypeName 'Nin.DiskUsageSummary' -MemberType ScriptProperty -MemberName 'RelativePath' -Value {
    $this.Path | Format-RelativePath -BasePath (Get-Item . )
} @splatForceIgnore 

Update-TypeData -TypeName 'Nin.DiskUsageSummary' -DefaultDisplayPropertySet RelativePath, SizeStr, FileCount, DirectoryCount @splatForceIgnore 