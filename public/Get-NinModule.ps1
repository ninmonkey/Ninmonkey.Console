
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



function _FormatExportedCommands {
    <#
    .synopsis
    should be cleaned up/refactored
    #>
    param(
        # Input object
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [psmoduleinfo[]]$ModuleInfo
    )

    process {
        $sort_CommandOrder = @{ # default sort order if converted to custom type
            Property = (
                @{Expression = 'Module'; Descending = $false },
                @{Expression = 'Command'; Descending = $false }
            )
        }

        $ModuleInfo | ForEach-Object {
            $CurModuleInfo = $_
            foreach ($Command in $CurModuleInfo.ExportedCommands.Values) {
                [pscustomobject]@{
                    Module      = $CurModuleInfo.Name
                    Command     = $Command
                    CommandType = $Command.CommandType
                    Version     = $Command.Version
                    Source      = $Command.Source
                    Name        = $Command.Name
                    FullName    = $Command.Source, $Command.Name -join '\'
                }
                $x = 3
            }
        }
        | Sort-Object @sort_CommandOrder
        #| Sort-Object -Property $SortBy.ModuleName_CommandName
    }

    # end {}
}

#  tests
# _FormatExportedCommands (Get-Module 'Ninmonkey.Console' -ListAvailable )
$ft_ExportedCommands = @{
    GroupBy  = 'Module'
    Property = 'Command'
}

_FormatExportedCommands (Get-Module 'Ninmonkey.*' -ListAvailable )
| Format-Table -Wrap -AutoSize
# | Format-Table *
# | Format-Table @ft_ExportedCommands

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
        $ModuleInfo = Get-Module #-Name:$Name   #$Name #-ListAvailable
        | Sort-Object Name

        Switch ($OutputMode) {
            'Commands' {
                $result = _FormatExportedCommands $ModuleInfo
                # | Select-Object -Property Command
                | Join-String -sep "`n" {
                    @(
                        'dsfds'
                    )
                }
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
    end {
        Write-Warning 'WIP'
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