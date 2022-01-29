if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'Get-CommandSummary'
    )
    $script:publicToExport.alias += @(
        'HelpCommmand'
        'Help->Commmand'
    )
}
function Get-CommandSummary {
    <#
    .synopsis
        describe commands quickly
    .notes
        Better display if I make a custom type, rather than adding members
            or else: Add-Member a new 'PSTypeName' that uses

            ft | Module, Command, Synopsis
    .example
        Find-NinCommand *template* | Get-CommandSummary
    #>
    [Alias('HelpCommand', 'Help->Command')]
    [cmdletbinding(PositionalBinding = $false)]
    param(
        # CommandName[s]
        [Alias('Name')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
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
        # $query = Get-Command -Name $CommandName -Module $ModuleName -ea silentlycontinue
        # # $commands 1= $query | Where-Object CommandType -NotIn 'AliasInfo', 'ApplicationInfo'
        # $commands = $query | Where-Object { $_.CommandType -notin @('alias', 'application') }
        # $alias = @(
        #     Get-Command -Name $CommandName -CommandType Alias -ea silentlycontinue
        #     Get-Command -Module $ModuleName -CommandType Alias -ea silentlycontinue
        # )


        $metaDebug = @{
            Commands = $commands | Join-String -Separator ', '
            Alias    = $Alias | Join-String -Separator ', '
        }



        $final = $CommandName | ForEach-Object {
            $curCmd = $_
            $helpObj = Get-Help $curCmd
            # $ResolvedCommand = (Get-Command -ErrorAction ignore $curCmd) # ?? 'NotFound?'
            $ResolvedCommand = Resolve-CommandName -CommandName $curCmd

            # I want multi-line output like psreadline
            #      PS> Get-PSReadLineKeyHandler -Bound | ? Group -match 'history' | % gettype
            $cmdSummary = @{
                PSTypeName      = 'Nin.CommandSummary'
                ResolvedCommand = $ResolvedCommand
                Name            = $ResolvedCommand.Name
                Description     = $ResolvedCommand.description
                Source          = $ResolvedCommand.Source
                HelpUri         = $ResolvedCommand.HelpUri
                CommandType     = $ResolvedCommand.CommandType

            }
            $AnyMatch = $false
            foreach ($regex in $ModuleName) {
                if ($ResolvedCommand.Source -match $regex) {
                    $AnyMatch = $true;
                    break;
                }
            }
            if (! $ModuleName) {
                $AnyMatch = $true
            }
            if (! $AnyMatch) {
                return
            }

            if ($false) {
                [pscustomobject]$cmdSummary
                return
            }

            if ($true) {
                $DescString = @(
                    $helpObj.Synopsis
                    "`n"
                    $helpObj.Description.Text
                ) | Join-String
                # $helpObj.Description.Text | rg '`.+?`' --color=always
                $helpObj.Description.Text
                $DescriptionColor = @(
                    $Help.Synopsis
                    Hr 1
                    $helpObj.Description.Text | ForEach-Object { $_ -replace '(`.+?`)', ( New-Text $_ -fg red ) }
                ) -join ''
                # ) | Join-String -sep ' ⸺ ⟶⟹ '

                $cmdSummary.DescriptionColor = $DescriptionColor
                $cmdSummary.DescStr = $DescString[0..300] -join ''
                # $cmd | Add-Member -NotePropertyName 'Description' -NotePropertyValue ($DescString[0..300] -join '') -PassThru -ea ignore
                # $cmd = $cmd | Add-Member -Force -NotePropertyName 'Description' -NotePropertyValue $DescString -PassThru -ea ignore
                # $cmd = $cmd | Add-Member -Force -NotePropertyName 'DescriptionColor' -NotePropertyValue $DescStringColor -PassThru -ea ignore
                # $cmd
            }
            [pscustomobject]$cmdSummary;
            return
        }
        # $helpObj | Join-String -Separator "`n" -Property { $_.description }

        $final

        [pscustomobject]$metaDebug | Format-List | Out-String | Write-Information


    }
    end {
        Write-Warning 'Found this old script, still super rough. will dump most of it.'
    }
}
# if ($false -and (! $script:publicToExport)) {
#     # working example
#     return
#     $f = Get-Module dev.nin | ForEach-Object ExportedCommands | ForEach-Object Keys | Select-Object -First 20
#     | Get-CommandSummary -ea ignore -ModuleName dev.nin

#     $f | ForEach-Object DescStr


#     if ($false -and $EnableDebugInline) {
#         Get-CommandSummary dev-Printtabletemplate -ea Continue -Verbose -Debug -infa Continue
#         # | ForEach-Object {

#         Get-CommandSummary dev-Printtabletemplate -ea Continue -Verbose -Debug -infa Continue
#         Get-CommandSummary dev-Printtabletemplate -ea Continue -Verbose -Debug -infa Continue

#         # Get-Command *console* -Module Ninmonkey.Console | ForEach-Object name | Sort-Object |

#         # Get-Alias -Definition 'write-consoleheader' | ForEach-Object name
#         $sample = Get-Command 'ls', 'Get-ConsoleEncoding', 'ls.exe'

#         $getCommandSummarySplat = @{
#             InformationAction = 'Continue'
#             CommandName       = 'ls', 'Get-ConsoleEncoding', 'ls.exe', 'write-consolecolor', 'Write-ConsoleHeader'
#         }

#         $test1 = Get-CommandSummary @getCommandSummarySplat
#         $test1

#     }

# }
