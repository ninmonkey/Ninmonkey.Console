
Update-FormatData -PrependPath (Get-Item -ea Continue 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\public\FormatData\nin-System.RuntimeType.ps1xml' )

# format data: Wasn't working
if ($false) {
    $formatData = @(
        'System.RuntimeType'
    )
    foreach ($file in $formatData) {
        $FileName = ("{0}\public\FormatData\nin-{1}.ps1xml" -f $psscriptroot, $file)
        if (Test-Path $FileName ) {
            Update-FormatData -AppendPath $FileName
        } else {
            Write-Error "Import: failed: FormatData: $File"
        }
    }
}

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

Export-ModuleMember -
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
    'Format-ControlChar'
    'Get-NinTypeData'
    # 'Get-NinFormatData'
    'Set-NinLocation'
    'Set-ConsoleEncoding'
    'Start-LogTestNet'
    'Test-Net'
    'Get-EnumInfo'
    'Format-FileSize'
    'Test-IsDirectory'
    'Get-NinCommandSyntax'
    'Invoke-Explorer'
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
    'Invoke-Explorer'
    'Format-FileSize'
    'Format-ControlChar'
    'Test-IsDirectory'
    'Set-NinLocation'
    'Get-NinCommandSyntax'
    'Get-NinTypeData'
    # 'Get-NinFormatData'
    'Format-History'
    'Get-TerminalName'
    'Write-AnsiHyperlink'
    'Format-MeasureCommand'
    'Format-TestConnection'
    'Get-ConsoleEncoding'
    'Get-Docs'
    'Get-EnumInfo'
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
    New-Alias 'Docs' -Value 'Get-Docs' -Description 'Jump to docs by language'
    New-Alias 'IPython' -Value 'Invoke-IPython' -Description 'ipython.exe defaults using my profile'
    New-Alias 'Goto' -Value Set-NinLocation -Description 'a more flexible version of Set-Location / cd'
    New-Alias 'Here' -Value Invoke-Explorer -Description 'Open paths in explorer' -ea Ignore

    $aliasesToExport = @(
        'Goto'
        'Docs'
        'IPython'
        'Here'
    )

    Export-ModuleMember -Alias $aliasesToExport
}