
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



function _FilterExportedCommands {
    param(
        # Input object
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
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
        # Module name
        [Parameter(Position = 0)]
        [string[]]$Name,

        # Output mode
        # later it might make sense to maek this [string[]]
        # if they are not exclusive
        [Parameter(Position = 1)]
        [ValidateSet('Commands', 'Summary', 'Uri', 'All')]
        [string]$OutputMode = 'Summary',

        # return an object
        [Parameter()][switch]$PassThru
    )

    begin {
        $Prop = @{}
        # Sorting here only guarantees order when not using wildcards
        $Prop.SummaryList = 'Name', 'Description', 'Version', 'ModuleType', 'Author', 'Path', 'ImplementingAssembly', 'HelpInfoUri', 'ModuleBase', 'Tags', 'ProjectUri'
        | Sort-Object
        $Prop.SummaryTable = 'Name', 'Description', 'Version', 'Author', 'Tags', 'ProjectUri'
        | Sort-Object
        $Prop.UriList = '*Uri*'
        | Sort-Object
    }



    process {
        $ModuleInfo = Get-Module $Name -ListAvailable
        | Sort-Object Name

        Switch ($OutputMode) {
            'Commands' {
                $result = _FilterExportedCommands $ModuleInfo
                | Select-Object -Property Command
                $result
                break
            }
            'Uri' {
                $result = $ModuleInfo | Select-Object -Property $Prop.UriList
                $result
                break
            }
            'Summary' {
                # 'LicenseUri'
                $result = $ModuleInfo | Select-Object -Property $Prop.SummaryTable
                if ($PassThru) {
                    $result
                }

                # removed -passthrough because: format-table does not fit some/all packages#
                # $result | Format-Table -Wrap -AutoSize
                break

            }
            default {
                $ModuleInfo
                break
            }
        }
    }

}
<#
visual tests:

if ($false) {
    # Import-Module Ninmonkey.Console -Force
    Get-NinModule pansies Uri
    | Format-List

    $x = (Get-NinModule pansies Uri  -PassThru)
    $x | Sort-Object
    | Format-List *
}
#>