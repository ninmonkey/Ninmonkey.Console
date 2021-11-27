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


# hardCoded until created
# see: <C:\Users\cppmo_000\Documents\2021\Powershell\My_Github\Dev.Nin\public_experiment\main_import_experimental.ps1>

# try {
# $fileList = @(
#     # 'Get-CommandSummary-OldMethod'
#     'Get-CommandSummafry'
#     'Find-Exception'
# )

# Don't dot tests, don't call self.
Get-ChildItem -File -Path (Get-Item -ea stop $PSScriptRoot)
| Where-Object { $_.Name -ne '__init__.ps1' }
| Where-Object {
    # are these safe? or will it alter where-object?
    # Write-Debug "removing test: '$($_.Name)'"
    $_.Name -notmatch '\.tests\.ps1$'
}
| ForEach-Object {
    # are these safe? or will it alter where-object?
    # Write-Debug "[dev.nin] importing experiment '$($_.Name)'"
    $curScript = $_
    try {
        . $curScript
    } catch {
        # Write-Error -Exception $_ -Message "DotsourceImportFailed: public_autoloader\__init__.ps1: '$($curScript)'" -TargetObject $_ -Category InvalidOperation
        Write-Error "todo: correctly throw: '$_'"
    }
}
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
