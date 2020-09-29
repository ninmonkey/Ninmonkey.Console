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
    'Get-RipGrepChildItem'
    'Edit-GitConfig'
    'Format-MeasureCommand'
    'Get-Docs'
    'Format-History'
    'Get-NinModule'
    'Format-Hashtable'
    'Format-TestConnection'
    'ipython'
    'Test-Net'
)
Export-ModuleMember -Function $functionsToExport


New-Alias 'Docs' -Value 'Get-Docs' -Description 'Jump to docs by language' -PassThru
$aliasesToExport = @(
    'Docs'
)


Export-ModuleMember -Alias $aliasesToExport