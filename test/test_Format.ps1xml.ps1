$BasePath = Get-Item -ea stop "$PSScriptRoot\.."

# $formatterList = Get-ChildItem "$BasePathpublic\FormatData\*.Format.ps1xml*"
$splat_GetFormatter = @{
    # Recurse = $true
    Path   = "$BasePath\public\FormatData"
    Filter = '*.Format.ps1xml*"'
}

$formatterList = Get-ChildItem @splat_GetFormatter
$splat_GetTypes = @{
    # Recurse = $true
    Path   = "$BasePath\public\TypeData"
    Filter = '*.Type.ps1xml*"'
}

$typesList = Get-ChildItem @splat_GetTypes

H1 'Test: Update-FormatData'
$formatterList.Name
H1 'Test: Update-TypeData (NYI)1'
$typesList.Name

$formatterList | ForEach-Object {
    H1 "testing: $_"
    Update-FormatData -AppendPath $_
}

# Update-FormatData -AppendPath 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\public\FormatData\*'
