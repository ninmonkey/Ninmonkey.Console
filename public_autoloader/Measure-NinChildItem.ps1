using namespace Management.Automation

$script:publicToExport.function += @('Measure-NinChildItem')
$script:publicToExport.alias += @('measureLs')

function Measure-NinChildItem {
    <#
    .synopsis
        Console/Minimal wrapper for Measure-ChildItem
    .description
        PS> Measure-ChildItem
    .description
        PS> Measure-ChildItem -path '.'
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
        [Nin.Diskusage[]]
    #>
    [alias('measureLs')]
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
                Write-Error "'Invalid Path: $curPath'"
                return
            }
            # $bytes = Measure-ChildItem -Path $curPath -Unit B -ValueOnly
            $query = Measure-ChildItem -Path $curPath -Unit B #-ValueOnly
            [pscustomobject]@{
                'PSTypeName'     = 'Nin.DiskUsageSummary'
                'Path'           = Get-Item $query.'Path'
                'Bytes'          = [Int64]$query.'Size'
                'SizeStr'        = $query.'Size' | Format-FileSize # convert to dynamic value ?
                # 'Size'           = [int64]$query.'Size'
                'FileCount'      = $query.'FileCount'
                'DirectoryCount' = $query.'DirectoryCount'
            }

        }
    }
}
