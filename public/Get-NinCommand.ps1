# $SortBy.ModuleName_CommandName = @(
#     @{ e = 'Module'; Descending = $False }
#     @{ e = 'Command'; Descending = $False }
# )
# $SortBy_Module_Command = $SortBy.ModuleName_CommandName
using namespace System.Management.Automation
function _FilterFunctionInfo {
    param(
        [Parameter(Mandatory, Position = 0, HelpMessage = 'inputObject', ValueFromPipeline)]
        [ValidateNotNull()]
        # [FunctionInfo[]]$FunctionInfo
        [object[]]$CmdletInfo
    )
    begin {
        $Prop = @{}
        # $Prop.SummaryList = 'Name', 'Description', 'Version', 'ModuleType', 'Author', 'Path', 'ImplementingAssembly', 'HelpInfoUri', 'ModuleBase', 'Tags', 'ProjectUri',
        $Prop = @{
            AliasInfo    = @{}
            CmdletInfo   = @{}
            FunctionInfo = @{}
        }
        $Prop.SummaryList = @(
            # 'CmdletBinding'
            'Name'
            'ResolvedCommandName'
        )

        Label 'PropertyLists' | Write-Debug
        $Prop | Format-Table | Out-String |  Write-Debug
    }

    process {
        if ($null -eq $_) {
            return
        }
        if ($_ -isnot 'AliasInfo' -or $_ -isnot 'CmdletInfo' -or $_ -isnot 'Functioninfo' ) {
            throw "Unknown type: $($_.GetType().Fullname)"
        }

        "CmdletInfo: $($CmdletInfo.GetType().Name)" | Write-Debug
        $CmdletInfo | ForEach-Object {
            $CurCmdletInfo = $_
            "CurCmdletInfo: $($CurCmdletInfo.GetType().Name)" | Write-Debug
            <#
            is both types:
                [CmdletInfo]
                [CommandInfo]

            #>
            # foreach ($Command in $CurCmdletInfo.ExportedCommands.Keys) {
            h1 'SummaryTable' | Write-Debug
            # $CurCmdletInfo
            # | Select-Object -Property $Prop.SummaryTable
            # | Format-Table -Wrap -AutoSize

            # h1 'SummaryList'
            # $CurCmdletInfo
            # | Select-Object -Property $Prop.SummaryList
            # | Format-List *
            #     $Command
            # } | Select-Object *
            # foreach ($Command in $CurCmdletInfo.psobject.properties) {
            #     [pscustomobject]@{
            #         Name  = $_.Name
            #         Value = $_.Value
            #         # Command = $CurCmdletInfo
            #         # Module  = $CurCmdletInfo.Name
            #         # Command = $Command
            #     }
            # }
        }
        #| Sort-Object -Property $SortBy.ModuleName_CommandName
    }

    # end {}
}

function Get-NinCommand {
    <#
    .description
        nicer output from get-command
    .notes
        future 'gcm' parameters:
            -UseFuzzyMatching
            -UseAbbreviationExpansion
    #>
    param(
        [Parameter(
            Position = 0,
            HelpMessage = "Command Name"
        )]
        [string[]]$Name,

        [Parameter(
            Position = 1,
            HelpMessage = 'Output Mode'
        )]
        # later it might make sense to maek this [string[]]
        # if they are not exclusive
        [ValidateSet('Commands', 'Summary')]
        [string]$OutputMode,

        [Parameter()][switch]$PassThru
    )

    begin {

    }

    process {
        $CommandInfo = Get-Command $Name
        | Sort-Object Name

        Switch ($OutputMode) {
            # 'Commands' {
            # }
            default {
                # @($CommandInfo)[0].GetType().FullName
                _FilterFunctionInfo $CommandInfo -Verbose -Debug
                # | Format-Table Command -GroupBy Module
                break
            }
            # 'Summary' {

            #     # 'LicenseUri'

            #     $result = $CommandInfo | Select-Object -Property $Prop.SummaryTable
            #     if ($PassThru) {
            #         $result
            #     } else {
            #         $result | Format-Table -Wrap -AutoSize
            #     }
            #     break

            # }
            # default {
            #     $CommandInfo
            #     break
            # }
        }
    }

}

$sampleCommands = @(
    Get-Command * | Where-Object { $_ -is 'AliasInfo' } | Select-Object -First 1
    Get-Command * | Where-Object { $_ -is 'CmdletInfo' } | Select-Object -First 1
    Get-Command * | Where-Object { $_ -is 'FunctionInfo' } | Select-Object -First 1
)

Label 'Sample commands'
$sampleCommands | Select-Object -Property  Name | Out-Default

h2 'misc commands samples'
Get-NinCommand 'Get-Command', 'Get-ChildItem'

h2 'now samples'
$sampleCommands | ForEach-Object {
    _FilterFunctionInfo $_
}
