
<#
# todo: filter when multiple modules have the same names
# to force the newest version of the same module:
Get-Module pester -ListAvailable
| Sort-Object -Property Version -Descending | Sort-Object -Unique -Property Name
| Format-Table Name, Version

#>

$SortBy = @{}

$SortBy.ModuleName_CommandName = @(
    @{ e = 'Module'; Descending = $False }
    @{ e = 'Command'; Descending = $False }
)
$SortBy_Module_Command = $SortBy.ModuleName_CommandName

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
        [ValidateSet('Commands')]
        [string]$OutputMode,

        [Parameter()][switch]$PassThru
    )

    process {
        $ModuleInfo = Get-Module $Name -ListAvailable
        | Sort-Object Name

        Switch ($OutputMode) {
            'Commands' {
                _FilterExportedCommands $ModuleInfo
                | Format-Table Command -GroupBy Module
                break
            }
            default {
                $ModuleInfo
                break
            }
        }
    }

}
if ($false) {

    $editmodules = Get-Module *EditorServices* -ListAvailable

    $editmodules | ForEach-Object {
        $ModuleName = $_
        foreach ($command in $ModuleName.ExportedCommands.Keys) {
            [pscustomobject]@{ Module = $ModuleName; Command = $command }
        }
    }

    if ($PassThru) {
        $editmodules
    }

    Format-Table Command -GroupBy Module

    $editmodules
}

Get-NinModule '*EditorServices*' | Format-Table Command -GroupBy Module
