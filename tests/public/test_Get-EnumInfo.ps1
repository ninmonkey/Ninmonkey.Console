
$TestConfig = @{
    AllImportableTypes     = $false
    AllImportableTypesMini = $true
    HardCoded              = $true
    ConvertAsPester        = $false
}

# "{0}`n`t{enum [IO.Compression.CompressionMode]
if ($null -eq $allEnumTypes -or $null -eq $allEnumTypes2) {
    $allEnumTypes = Find-Type -Base enum | ForEach-Object FullName
    $allEnumTypes2 = Find-Type -InheritsType 'System.Enum' | ForEach-Object FullName

    # throw "expected equal enumType list"
}

"Totals: $($allEnumTypes.count), $($allEnumTypes2.count)"



if ($TestConfig.AllImportableTypes) {
    $allEnumTypes | Get-EnumInfo
}
if ($TestConfig.AllImportableTypes) {
    # $allEnumTypes | Get-EnumInfo
}

if ($TestConfig.HardCoded) {


    $sample = @(
        [System.IO.Compression.compressionMode]
        [ConsoleColor]
        [IO.FileAttributes]
    )



    $sample | ForEach-Object {
        '';
        $_ | Get-EnumInfo
    }
    # $sample | Get-EnumInfo
}

if ($TestConfig.ConvertAsPester) {




    $expected = "enum [IO.Compression.CompressionMode]`n`tDecompress, Compress"
    $result = [IO.Compression.CompressionMode] | Get-EnumInfo
    hr
    $result
    hr
    $expected
    hr
    $result | Should -be $expected

    hr 10
    $expected = @'
enum [IO.Compression.CompressionMode]
	Decompress, Compress
'@
    hr
    $result
    hr
    $expected
    hr
    # ($result -split '\r?\n' -join "`n" ) | Should -be $expected
    ($result -join "`n" ) | Should -be $expected
    # enum [IO.Compression.CompressionMode]
    # Decompress, Compress


}
