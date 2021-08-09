
function Get-CommandSummary {
    [cmdletbinding(PositionalBinding = $false)]
    param(
        # CommandName[s]
        [Parameter(Mandatory, Position = 0)]
        [string[]]$CommandName,

        # source module
        [Parameter(Position = 1)]
        [string[]]$ModuleName
    )
    process {
        <#
            [System.Management.Automation.AliasInfo]
            [System.Management.Automation.FunctionInfo]
            [System.Management.Automation.ApplicationInfo]
        s#>
        Write-Warning 'still WIP, unstable.'
        $query = Get-Command -Name $CommandName -Module $ModuleName -ea silentlycontinue
        # $commands 1= $query | Where-Object CommandType -NotIn 'AliasInfo', 'ApplicationInfo'
        $commands = $query | Where-Object { $_.CommandType -notin @('alias', 'application') }
        $alias = @(
            Get-Command -Name $CommandName -CommandType Alias -ea silentlycontinue
            Get-Command -Module $ModuleName -CommandType Alias -ea silentlycontinue
        )

        $metaDebug = @{
            Commands = $commands | Join-String -Separator ', '
            Alias    = $Alias | Join-String -Separator ', '
        }

        $final = $Commands | ForEach-Object {
            $cmd = $_
            $helpObj = Get-Help $cmd
            $DescString = @(
                $helpObj.Synopsis
                "`n"
                $helpObj.Description.Text
            ) | Join-String
            # $helpObj.Description.Text | rg '`.+?`' --color=always
            $helpObj.Description.Text
            $DescriptionColor = @(
                $Help.Synopsis
                hr 1
                $helpObj.Description.Text | ForEach-Object { $_ -replace '(`.+?`)', ( New-Text $_ -fg red ) }
            )
            # ) | Join-String -sep ' ⸺ ⟶⟹ '

            # $cmd | Add-Member -NotePropertyName 'Description' -NotePropertyValue ($DescString[0..300] -join '') -PassThru -ea ignore
            $cmd = $cmd | Add-Member -Force -NotePropertyName 'Description' -NotePropertyValue $DescString -PassThru -ea ignore
            $cmd = $cmd | Add-Member -Force -NotePropertyName 'DescriptionColor' -NotePropertyValue $DescStringColor -PassThru -ea ignore



        }
        # $helpObj | Join-String -Separator "`n" -Property { $_.description }

        $final
        [pscustomobject]$metaDebug | Format-List | Out-String | Write-Information


    }
}
# | ForEach-Object {
if ($false) {

    # Get-Command *console* -Module Ninmonkey.Console | ForEach-Object name | Sort-Object |

    # Get-Alias -Definition 'write-consoleheader' | ForEach-Object name
    $sample = Get-Command 'ls', 'Get-ConsoleEncoding', 'ls.exe'

    $getCommandSummarySplat = @{
        InformationAction = 'Continue'
        CommandName       = 'ls', 'Get-ConsoleEncoding', 'ls.exe', 'write-consolecolor', 'Write-ConsoleHeader'
    }

    $test1 = Get-CommandSummary @getCommandSummarySplat
    $test1

}
