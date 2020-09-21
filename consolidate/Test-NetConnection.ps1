

'test cases'
& {
    h1 'def -> FormatTestConnection -detail'
    Test-Connection google.com -Count 1 | Format-TestConnection -Detailed
    h1 'def -> FormatTestConnection'
    Test-Connection google.com -Count 1 | Format-TestConnection

    h1 'Test-Net -PassThru'
    Test-Net google.com -PassThru
    h1 'Test-Net -PassThru -Detailed'
    Test-Net google.com -PassThru -Detailed

    h1 'Test-Net -Detailed'
    Test-Net google.com -Detailed
    h1 'Test-Net'
    Test-Net google.com

}
# if ($preformat) {
#     $preformat | Format-TestConnection -Verbose -Debug
# }
Test-Net 'google.com' #-Verbose -Debug # | Select-Object *
# Write-Warning 'todo: custom format for this type''s default output as FT'

# format results
# exit
# $results = Test-Net

# $DisableCache = $false
# if ($DisableCache -or !$cachedResults) {
#     $cachedResults = Test-Net
# }
# $cachedResults | Format-TestConnection -Debug -Verbose


# Test-Connection '8.8.8.8' -Count 1 | ForEach-Object {
#     $_ | Add-Member -NotePropertyName 'TimeWas' -NotePropertyValue (Get-Date)
# # } | Select-Object *
# Test-Connection '8.8.8.8' -Count 1 | ForEach-Object {
#     $_ | Add-Member -NotePropertyName 'TimeWas' -NotePropertyValue 'now'
# } | Select-Object *