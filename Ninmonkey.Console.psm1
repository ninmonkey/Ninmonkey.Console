$private = @(

)

foreach ($file in $private) {
    if (Test-Path ("{0}\private\{1}.ps1" -f $psscriptroot, $file)) {
    } else {
        Write-Error "Import: failed: private: $File"
    }
    . ("{0}\private\{1}.ps1" -f $psscriptroot, $file)
}

$public_NativeWrapper = @(
    'Invoke-IPython'
    # 'Invoke-RipGrepChildItem'
)
foreach ($file in $public_NativeWrapper) {
    if (Test-Path ("{0}\public\native_wrapper\{1}.ps1" -f $psscriptroot, $file)) {
    } else {
        Write-Error "Import: failed: public\native_wrapper: $File"
    }
    . ("{0}\public\native_wrapper\{1}.ps1" -f $psscriptroot, $file)

}

Export-ModuleMember -Function $public_NativeWrapper

$completer = @(
    'Completer-dotnet'
    'Completer-RipGrep'
    'Completer-gh'
)

foreach ($file in $completer) {
    if (Test-Path ("{0}\public\completer\{1}.ps1" -f $psscriptroot, $file)) {
    } else {
        Write-Error "Import: failed: completer: $File"
    }
    . ("{0}\public\completer\{1}.ps1" -f $psscriptroot, $file)
}

Export-ModuleMember -Function $completer

$public = @(
    'Edit-GitConfig'
    'Export-PlatformFolderPath'
    'Format-Hashtable'
    'Format-History'
    'Format-MeasureCommand'
    'Format-TestConnection'
    'Get-ConsoleEncoding'
    'Get-Docs'
    'Test-UserIsAdmin'
    'Write-AnsiHyperlink'
    'Get-NinModule'
    'Set-ConsoleEncoding'
    'Start-LogTestNet'
    'Test-Net'
    'Get-TerminalName'
)

foreach ($file in $public) {
    if (Test-Path ("{0}\public\{1}.ps1" -f $psscriptroot, $file)) {
    } else {
        Write-Error "Import: failed: public: $File"
    }
    . ("{0}\public\{1}.ps1" -f $psscriptroot, $file)
}



$functionsToExport = @(
    'Edit-GitConfig'
    'Export-PlatformFolderPath'
    'Format-Hashtable'
    'Test-UserIsAdmin'
    'Format-History'
    'Get-TerminalName'
    'Write-AnsiHyperlink'
    'Format-MeasureCommand'
    'Format-TestConnection'
    'Get-ConsoleEncoding'
    'Get-Docs'
    'Get-NinModule'
    'Invoke-IPython'
    'Invoke-RipGrepChildItem'
    'Set-ConsoleEncoding'
    'Start-LogTestNet'
    'Test-Net'
)
Export-ModuleMember -Function $functionsToExport

if ($true) {
    # toggle auto importing of aliases', otherwise only use new-alias
    New-Alias 'Docs' -Value 'Get-Docs' -Description 'Jump to docs by language'# -PassThru
    New-Alias 'IPython' -Value 'Invoke-IPython' -Description 'ipython.exe defaults using my profile' -PassThru

    $aliasesToExport = @(
        'Docs'
        'IPython'
    )

    Export-ModuleMember -Alias $aliasesToExport
}