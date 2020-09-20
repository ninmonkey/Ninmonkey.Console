$private = @(

)

foreach ($file in $private) {
    . ("{0}\private\{1}.ps1" -f $psscriptroot, $file)
}

$public = @(
    'Format-Hashtable'
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
    'Format-Hashtable'
)
Export-ModuleMember -Function $functionsToExport
