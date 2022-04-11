#Requires -Version 7.0

using namespace system.collections.generic
# __init__.ps1
# eaiser to manage and filter, especially a dynamic set, in one place
[hashtable]$script:publicToExport = @{
    'function' = @()
    'alias'    = @()
    'cmdlet'   = @()
    'variable' = @()
    'meta'     = @()
    # 'formatData' = @()
}

class ModuleExportRecord {
    # future:// param that auto-logs when property is changed
    # maybe this is one instance per file
    # which gets appended to global state?
    [List[object]]$function = [List[object]]::new()
    [List[object]]$alias = [List[object]]::new()
    [List[object]]$cmdlet = [List[object]]::new()
    [List[object]]$variable = [List[object]]::new()
    [List[object]]$typeData = [List[object]]::new()   # nyi
    [List[object]]$formatData = [List[object]]::new() # nyi

    # store source filename etc?

    [List[object]]$meta = [List[object]]::new() # nyi
}

$ModuleExportRecord = [ModuleExportRecord]::new()

class NinModuleInfo {
    # global state
    #  PSRealine Exports
    # command line completers
    [ModuleExportRecord[]]$ExportInfo = [list[ModuleExportRecord]]::new()
    [object]$PSReadlineHandlers # or hooks
    [object]$NativeCommand
}

$script:ninModuleInfo

$strUL = @{
    'sep' = "`n  - "
    'op'  = "`n  - "
    'os'  = "`n"
}

function Get-DirectChildItem {
    <#
    .synopsis
        Find all children of a type, includes hidden
    .description
        sugar for:
            Get-ChildItem -Directory
            | ForEach-Object{ Get-ChildItem $_ -Directory }
    #>
    [OutputType([System.IO.DirectoryInfo], [System.IO.FileInfo] )]
    [cmdletbinding()]
    param(
        # root dir to search. maybe allow paths pipeled
        [Alias('PSPath')]
        [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]$Path = '.',

        # only folders
        [switch]$Directory,
        # only files
        [switch]$File
    )
    process {
        if ($Directory) {
            $lsArgs = @{ 'Directory' = $true }
        }
        if ($File) {
            $lsArgs = @{ 'File' = $true }
        }
        Get-ChildItem -Path $Path -Force
        | ForEach-Object { Get-ChildItem $_ -Force }
    }
}

# $ModuleExportRecord.function.Add( 'Get-DirectChildItem' )

[ModuleExportRecord]@{
    'function' = 'Get-DirectChildItem'
}

$ninModuleInfo

# hardCoded until created
# see: <C:\Users\cppmo_000\Documents\2021\Powershell\My_Github\Dev.Nin\public_experiment\main_import_experimental.ps1>

# try {
# $fileList = @(
#     # 'Get-CommandSummary-OldMethod'
#     'Get-CommandSummafry'
#     'Find-Exception'
# )


# $x = $null
# return
$dirsToLoad = Get-ChildItem '.' '__init__.ps1' -Recurse -Force
| ForEach-Object Directory

$dirsToLoad | Write-Host -foreg Green
$dirsToLoad
| Sort-Object { $_.FullName -match 'beforeAll' }-Descending  # future will allow sort order from '__init__.ps1'
# |  % fullname

$DirsToLoad | Join-String @strUL | Write-Verbose
$DirsToLoad | Join-String @strUL { $_.Name } | Write-Debug
# | Write-Information
'before'

$ModuleExportRecord | ConvertTo-Json -Depth 50 | Set-Content temp:\last_ModuleExportRecord.json -Encoding utf8
Get-Content temp:\last_ModuleExportRecord.json -Encoding utf8 | bat -l json -f -p | Write-Information
$z = $Null

return

Write-Warning 'here ->> todo: shared __findImportableChildItems...'
# todo: shared clean and required conditions 2022-03-30
# Don't dot tests, don't call self.
Get-ChildItem -File -Path (Get-Item -ea stop $PSScriptRoot)
| Where-Object { $_.Name -ne '__init__.ps1' }
| Where-Object { $_.Name -ne '__init__.first.ps1' }
| Where-Object { $_.Name -match '\.ps1$' }
| Where-Object { $_.Name -notmatch '\.tests\.ps1$' }
| ForEach-Object {
    $curScript = $_
    . $curScript
}
# are these safe? or will it alter where-object?
# Write-Debug "[dev.nin] importing experiment '$($_.Name)'"
# } catch {
# Write-Error -Exception $_ -Message "DotsourceImportFailed: public_autoloader\__init__.ps1: '$($curScript)'" -TargetObject $_ -Category InvalidOperation
# Write-Error "todo: correctly throw: '$_'"
# }
# } catch {
# Write-Error "public_autoloader\__init__.ps1:  failed`ntodo: correctly throw: '$_'"
# Write-Error -Exception $_ -Message ''
# }

$script:publicToExport | Join-String -op 'ExperimentToExport' | Write-Debug

if ($script:publicToExport['function']) {
    Export-ModuleMember -Function $script:publicToExport['function']
}
if ($script:publicToExport['alias']) {
    Export-ModuleMember -Alias $script:publicToExport['alias']
}
if ($script:publicToExport['cmdlet']) {
    Export-ModuleMember -Cmdlet $script:publicToExport['cmdlet']
}
if ($script:publicToExport['variable']) {
    Export-ModuleMember -Variable $script:publicToExport['variable']
}

$meta | Format-Table | Out-String | Write-Information



# $fileList | ForEach-Object {
#     $RelativePath = "$_.ps1"
#     $src = Join-Path $PSSCriptRoot $RelativePath
#     if (!(Test-Path $src)) {
#         Write-Error  "Unknown import: '$RelativePath'"
#         return
#     }
#     try {
#         . $src

#     }
# catch {
# One nuance of $PSCmdlet.ThrowTerminatingError() is that it creates a terminating error within your Cmdlet but it turns into a non-terminating error after it leaves your Cmdlet.
# but the pipeline ends regardless of a '-Ea Continue'
# $PSCmdlet.ThrowTerminatingError($PSItem)
# $_.InvocationInfo, and inner exception: <https://powershellexplained.com/2017-04-10-Powershell-exceptions-everything-you-ever-wanted-to-know/#psiteminvocationinfo>
# $PSCmdlet.ThrowTerminatingError($PSItem)
# Write-Error "Import failed '$RelativePath'" -Exception $_
# }
# }
# }
# catch {
# Write-Error -Exception $_ -Message 'autoloader failed'
# return
# throw -e
# throw $_
# }
# Export-ModuleMember -Function $funcList

# . (Join-Path $PSSCriptRoot 'Get-CommandSummary.ps1')
# Export-ModuleMember 'Get-CommandSummary-OldMethod'
