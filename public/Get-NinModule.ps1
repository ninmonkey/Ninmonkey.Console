
<#
# todo: filter when multiple modules have the same names
# to force the newest version of the same module:
Get-Module pester -ListAvailable
| Sort-Object -Property Version -Descending | Sort-Object -Unique -Property Name
| Format-Table Name, Version

#>

# Write-Warning 'these actually module wide scoped at run time: Ex: Get-NinModule.ps1'
# $SortBy = @{}

# $SortBy.ModuleName_CommandName = @(
#     @{ e = 'Module'; Descending = $False }
#     @{ e = 'Command'; Descending = $False }
# )
# $SortBy_Module_Command = $SortBy.ModuleName_CommandName

function ipython {
    <#
    .synopsis
        wrapper to auto import my profile on default
    .notes
        make position 0 = value from remaining args, profile is by name only.
        pass the rest to ipython.
    future:
        [ ] json configures default profile

    #>
    param([string]$ProfileName = 'ninmonkey')
    ipython.exe --profile=${ProfileName}
}


function _FilterExportedCommands {
    param(
        [Parameter(Mandatory, Position = 0, HelpMessage = 'inputObject', ValueFromPipeline)]
        [ValidateNotNull()]
        [psmoduleinfo[]]$ModuleInfo
    )

    process {
        $ModuleInfo | ForEach-Object {
            $CurModuleInfo = $_
            foreach ($Command in $CurModuleInfo.ExportedCommands.Keys) {
                [pscustomobject]@{
                    Module  = $CurModuleInfo.Name
                    Command = $Command
                }
            }
        }
        #| Sort-Object -Property $SortBy.ModuleName_CommandName
    }

    # end {}
}

#  tests
# _FilterExportedCommands (Get-Module 'Ninmonkey.Console' -ListAvailable )

function Get-NinModule {
    param(
        [Parameter(
            Position = 0,
            HelpMessage = "Module Name"
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
        $Prop = @{}
        $Prop.SummaryList = 'Name', 'Description', 'Version', 'ModuleType', 'Author', 'Path', 'ImplementingAssembly', 'HelpInfoUri', 'ModuleBase', 'Tags', 'ProjectUri'
        $Prop.SummaryTable = 'Name', 'Description', 'Version', 'Author', 'Tags', 'ProjectUri'
    }

    process {
        $ModuleInfo = Get-Module $Name -ListAvailable
        | Sort-Object Name

        Switch ($OutputMode) {
            'Commands' {
                _FilterExportedCommands $ModuleInfo
                | Format-Table Command -GroupBy Module
                break
            }
            'Summary' {

                # 'LicenseUri'

                $result = $ModuleInfo | Select-Object -Property $Prop.SummaryTable
                if ($PassThru) {
                    $result
                } else {
                    $result | Format-Table -Wrap -AutoSize
                }
                break

            }
            default {
                $ModuleInfo
                break
            }
        }
    }

}
