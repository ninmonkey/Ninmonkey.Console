# $SortBy.ModuleName_CommandName = @(
#     @{ e = 'Module'; Descending = $False }
#     @{ e = 'Command'; Descending = $False }
# )
# $SortBy_Module_Command = $SortBy.ModuleName_CommandName
using namespace System.Management.Automation


function _Format-ParameterTypeInfo {
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'ParameterMetadata instance')]
        [ParameterMetaData[]]$InputObject
    )

    process {
        $InputObject.GetEnumerator() | ForEach-Object {

            # is a: [ParameterMetadata]
            $curParam = $_
            $curName = $curParam.Key
            $curValue = $curParam.Value
            $hashParam = @{
                Name       = $curName
                Type       = $curValue.ParameterType
                ParamSets  = $curValue.ParameterSets
                IsDynamic  = $curValue.IsDynamic
                Aliases    = $curValue.Aliases
                Attributes = $curValue.Attributes
                IsSwitch   = $curVal.SwitchParameter

            }
            [pscustomobject]$hashParam
        }
    }
}
function _FilterFunctionInfo {
    param(
        [Parameter(Mandatory, Position = 0, HelpMessage = 'inputObject', ValueFromPipeline)]
        [ValidateNotNull()]
        # [FunctionInfo[]]$FunctionInfo
        [FunctionInfo[]]$FunctionInfo
    )
    begin {
        $Prop = @{}
        # $Prop.SummaryList = 'Name', 'Description', 'Version', 'ModuleType', 'Author', 'Path', 'ImplementingAssembly', 'HelpInfoUri', 'ModuleBase', 'Tags', 'ProjectUri',
        # $Prop = @{
        #     AliasInfo    = @{}
        #     CmdletInfo   = @{}
        #     FunctionInfo = @{}
        # }
        $Prop.DetailedList = @(
            # 'CmdletBinding'
            'CmdletBinding'
            'CommandType'
            'DefaultParameterSet'
            'Description'
            'HelpFile'
            'HelpUri'
            'Module'
            'ModuleName'
            'Name'
            'Noun'
            'Options'
            'OutputType'
            'Parameters'
            'ParameterSets'
            'RemotingCapability'
            'ResolvedCommandName'
            'Source'
            'Verb'
            'Version'
            'Visibility'
        )

        $Prop.SummaryList = @(

        )

        Label 'PropertyLists' | Write-Debug
        $Prop | Format-Table | Out-String |  Write-Debug
    }

    process {

        $FunctionInfo | ForEach-Object {
            $CurFunctionInfo = $_
            "CurFunctionInfo: $($CurFunctionInfo.GetType().Name)" | Write-Debug
            <#
            is both types:
                [CmdletInfo]
                [CommandInfo]

            #>
            # foreach ($Command in $CurFunctionInfo.ExportedCommands.Keys) {
            H1 'SummaryTable' | Write-Debug
            'wip'
            # $CurFunctionInfo | Select-Object * -ExcludeProperty 'ScriptBlock', 'Definition'
            # h2 'all'
            # $CurFunctionInfo  | Select-Object *

            h2 'summary list'

            $CurFunctionInfo | Select-Object -Property $Prop.DetailedList
            hr

            $metaParamInfo = $CurFunctionInfo.Parameters.GetEnumerator() | ForEach-Object {
                # is a: [ParameterMetadata]
                $curParam = $_
                $curName = $curParam.Key
                $curValue = $curParam.Value
                $hashParam = @{
                    Name       = $curName
                    Type       = $curValue.ParameterType
                    ParamSets  = $curValue.ParameterSets
                    IsDynamic  = $curValue.IsDynamic
                    Aliases    = $curValue.Aliases
                    Attributes = $curValue.Attributes
                    IsSwitch   = $curVal.SwitchParameter

                }
                [pscustomobject]$hashParam


            }

            h2 'metaParamInfo'
            $metaParamInfo
            # $CurFunctionInfo
            # | Select-Object -Property $Prop.SummaryTable
            # | Format-Table -Wrap -AutoSize
            Label 'pause'
            # h1 'SummaryList'
            # $CurFunctionInfo
            # | Select-Object -Property $Prop.SummaryList
            # | Format-List *
            #     $Command
            # } | Select-Object *
            # foreach ($Command in $CurFunctionInfo.psobject.properties) {
            #     [pscustomobject]@{
            #         Name  = $_.Name
            #         Value = $_.Value
            #         # Command = $CurFunctionInfo
            #         # Module  = $CurFunctionInfo.Name
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
        # Command name
        [Parameter(Position = 0)]
        [string[]]$Name,

        # output mode
        [Parameter(Position = 1)]
        # later it might make sense to maek this [string[]]
        # if they are not exclusive
        [ValidateSet('Commands', 'Summary')]
        [string]$OutputMode,

        # do not format
        [Parameter()][switch]$PassThru
    )

    begin {

    }

    process {
        throw "WIP"
        $CommandInfo = Get-Command $Name
        | Sort-Object Name

        if ($null -eq $_) {
            return
        }
        if ($_ -isnot 'AliasInfo' -or $_ -isnot 'CmdletInfo' -or $_ -isnot 'Functioninfo' ) {
            throw "Unknown type: $($_.GetType().FullName)"
        }

        "CmdletInfo: $($FunctionInfo.GetType().Name)" | Write-Debug


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

$Sample = @{
    AliasInfo              = Get-Command * | Where-Object { $_ -is 'AliasInfo' } | Select-Object -First 1
    AliasInfo_NonBlank     = Get-Command * | Where-Object { $_ -is 'AliasInfo' -and $null -ne $_.Version } | Select-Object -First 1

    CmdletInfo             = Get-Command * | Where-Object { $_ -is 'CmdletInfo' } | Select-Object -First 1
    CmdletInfo_NonBlank    = Get-Command * | Where-Object { $_ -is 'CmdletInfo' -and $null -ne $_.Version } | Select-Object -First 1

    FunctionInfo           = Get-Command * | Where-Object { $_ -is 'FunctionInfo' } | Select-Object -First 1
    FunctionInfo_NonBlank  = Get-Command * | Where-Object { $_ -is 'FunctionInfo' -and $null -ne $_.Version } | Select-Object -First 1
    FunctionInfo_WithParam = Get-Command * | Where-Object {
        $_ -is 'FunctionInfo' -and $null -ne $_.Version -and $_.Parameters.PSBase.Count -gt 0
    } | Select-Object -First 1 -Wait
}
$AllSamples = $Sample.Values
Label 'Sample commands'
$AllSamples | Select-Object -Property  Name | Out-Default

if ($False) {


    H1 'misc commands samples'
    Get-NinCommand 'Get-Command', 'Get-ChildItem'
    H1 'now samples'
    $sample.FunctionInfo, $sample.FunctionInfo_NonBlank | ForEach-Object {
        _FilterFunctionInfo $_
    }
    hr
    $Sample.FunctionInfo_WithParam.Parameters | _Format-ParameterMetaData
}


$g_paramDict = $Sample.FunctionInfo_WithParam.Parameters
$g_paramSingle = $Sample.FunctionInfo_WithParam.Parameters.GetEnumerator() | Select-Object -First 1 -ExpandProperty Value
