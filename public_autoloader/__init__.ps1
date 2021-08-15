# __init__.ps1

# hardCoded until created
# see: <C:\Users\cppmo_000\Documents\2021\Powershell\My_Github\Dev.Nin\public_experiment\main_import_experimental.ps1>



$fileList = @(
    # 'Get-CommandSummary-OldMethod'
    'Get-CommandSummary'
)

$fileList | ForEach-Object {
    $RelativePath = "$_.ps1"
    $src = Join-Path $PSSCriptRoot $RelativePath
    if (!(Test-Path $src)) {
        Write-Error  "Unknown import: '$RelativePath'"
        return
    }
    try {
        . $src

    }
    catch {
        # One nuance of $PSCmdlet.ThrowTerminatingError() is that it creates a terminating error within your Cmdlet but it turns into a non-terminating error after it leaves your Cmdlet.
        # $PSCmdlet.ThrowTerminatingError($PSItem)
        # $_.InvocationInfo, and inner exception: <https://powershellexplained.com/2017-04-10-Powershell-exceptions-everything-you-ever-wanted-to-know/#psiteminvocationinfo>
        # $PSCmdlet.ThrowTerminatingError($PSItem)
        Write-Error "Import failed '$RelativePath'" #-Exception
    }
}

# . (Join-Path $PSSCriptRoot 'Get-CommandSummary.ps1')
# Export-ModuleMember 'Get-CommandSummary-OldMethod'
# Export-ModuleMember 'Get-CommandSummary'
