$calcProp = @{}
$calcProp.TypeSummary = @{
    n = 'Type'
    e = {
        $_.GetType().Name
    }
}


[Microsoft.PowerShell.Commands.TestConnectionCommand+PingStatus].gettype() | ForEach-Object {
    $_.psobject.properties
}
# | Add-Member -NotePropertyName 'jType' -NotePropertyValue ( $_.value.gettype().Name ) -PassThru
| Where-Object TypeNameOfValue -Match 'impl|cust'
| Format-List
# | Format-Table Name, $calcProp.TypeSummary, TypeNameOfValue, value

# Test-Net