Import-Module Ninmonkey.Console -Force #| Out-Null
H1 'quick test'
$ConfigTest = @{
    'MaxInput'      = $true
    'NinCommand'    = $false
    'Temp'          = $false
    'CustomObject'  = $false
    'CustomObject2' = $false
    'GetCommand'    = $false
}

$ConfigTest | Format-HashTable -Title 'Config'

if ( $ConfigTest.MaxInput ) {
    0..4 | ForEach-Object { [string]$_ }
    | Prop

    hr
    0..4 | ForEach-Object { [string]$_ }
    | Prop -Limit 2

}
if ( $ConfigTest.NinCommand ) {
    Get-NinCommand
    _Format-Command
}


if ( $ConfigTest.Temp ) {
    # H1 'Prop output:'
    # Get-ChildItem . | Get-Unique -OnType | Select-Object -First 1 | Prop | Format-Table
    # (Get-Date) | Prop | Format-Table

    # Write-Warning 'bug:'


    <#
# is not returning properties on itself:
> @(34) | prop

> (34) | Prop | ExpectedToBe Blank

> @(34) | Prop | ExpectedToBe List

# Should be:
> $x.psobject.properties'
#>
}

if ( $ConfigTest.CustomObject ) {
    $catHash = @{'a' = 'cat'; age = 9; children = (0..4) }
    $catObj = [pscustomobject]$catHash

    H1 'Test1] Param'
    $gcm = Get-Command Select-Object
    $gcm.Parameters | Prop | Format-Table

    H1 'Test2] Basic Objects'
    $catHash | Prop | Format-Table
    $catObj | Prop | Format-Table
}

Hr

if ( $ConfigTest.CustomObject2 ) {

    $catHash = @{'a' = 'cat'; age = 9; children = (0..4) }
    $catObj = [pscustomobject]$catHash

    Label 'hash'
    $catHash | Prop # Get-ObjectProperty

    Label 'Obj'
    $catObj | Prop # Get-ObjectProperty
}
if ( $ConfigTest.GetCommand ) {
    $gcm = Get-Command Select-Object
    $gcm.Parameters | Prop | Format-List
    $gcm.Parameters | Prop | Format-Table
    $prop = $gcm.psobject.properties | Where-Object  Name -EQ Parameters # | % TypeNameOfValue
    $prop.TypeNameOfValue -as 'type' | Format-TypeName
}

$ConfigTest | Format-HashTable -Title 'Config'