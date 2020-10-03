$private = @(

)

foreach ($file in $private) {
    . ("{0}\private\{1}.ps1" -f $psscriptroot, $file)
}

$public = @(
    'Get-NinModule'
    'Format-Hashtable'
    'Format-TestConnection'
    'Test-Net'
    'Format-MeasureCommand'
    'Get-Docs'
    'Format-History'
    'Edit-GitConfig'
    'Export-PlatformFolderPath'
    'Get-RipGrepChildItem'
    'Set-ConsoleEncoding'
    'Get-ConsoleEncoding'
    'Invoke-IPython'
    'Start-LogTestNet'
)

foreach ($file in $public) {
    . ("{0}\public\{1}.ps1" -f $psscriptroot, $file)
}

$completer = @(
    'Completer-dotnet'
)

foreach ($file in $completer) {
    . ("{0}\public\completer\{1}.ps1" -f $psscriptroot, $file)
}

$functionsToExport = @(
    'Export-PlatformFolderPath'
    'Set-ConsoleEncoding'
    'Invoke-IPython'
    'Start-LogTestNet'
    'Get-ConsoleEncoding'
    'Get-RipGrepChildItem'
    'Edit-GitConfig'
    'Format-MeasureCommand'
    'Get-Docs'
    'Format-History'
    'Get-NinModule'
    'Format-Hashtable'
    'Format-TestConnection'
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