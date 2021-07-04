if ($false) {
    Import-Module Ninmonkey.Console -Force *>&1 | Out-Null
}
else {
    . (Get-Item -ea stop 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\public\Write-ConsoleText.ps1')

}
# Some tests are visual, or not Pester worthy
# This file is a scratchboard

# H1 'quick test'
$ConfigTest = @{
    'write-color' = $True
    'GetCommand'  = $false
}
# $ConfigTest | Format-HashTable -Title 'Config'

if ( $ConfigTest.'write-color' ) {
    # Write-ConsoleText 'green' -fg green


    # # Write-ConsoleText -
    # @(
    #     Write-ConsoleText 'green' -fg green
    #     Write-ConsoleText 'red' -fg orange
    # ) -join ', '
}
