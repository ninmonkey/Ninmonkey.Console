BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

<#
add:

if ($true) {
    # need to test: should test
    # 'System.System.System' | Format-TypeName -IgnorePrefix 'System' -ea Continue
    'system.text'.GetType() | Format-TypeName

}
#>

Describe "Format-TypeName" {
    It 'String: FileInfo' {
        'System.IO.FileInfo' | Format-TypeName
        | Should -Be 'IO.FileInfo'
    }

    It 'String: FileInfo' {
        'System.IO.FileInfo' | Format-TypeName
        | Should -Be '[IO.FileInfo]'
    }

    It 'String: FileInfo -IgnorePrefix "System.IO" -NoBrackets' {
        'System.IO.FileInfo' | Format-TypeName -IgnorePrefix 'System.IO' -NoBrackets
        | Should -Be 'FileInfo'
    }

    It 'TypeInfo instance: FileInfo' {
        $file = (Get-ChildItem . -Directory | Select-Object -First 1)
        $file.GetType() | Format-TypeName
        | Should -be 'IO.DirectoryInfo'
    }

    It 'TypeInfo instance: FileInfo' {
        $file = (Get-ChildItem . -Directory | Select-Object -First 1)
        $file.GetType() | Format-TypeName
        | Should -be '[IO.DirectoryInfo]'
    }

    It 'String: FileInfo -IgnorePrefix "System.IO" -NoBrackets' {
        $file = (Get-ChildItem . -Directory | Select-Object -First 1)
        $file.GetType() | Format-TypeName -IgnorePrefix 'System.IO' -NoBrackets
        | Should -Be 'DirectoryInfo'
    }

    It 'Pipe: Types as text -NoBrackets' {
        # $inputList = 'b.system.bar', 'Int32', 'foo', 'Object[]', 'foo[]'
        $inputList = 'b.system.bar', (23).GetType(), 'System.foo', 'System.Object[]', 'foo[]'
        $expected = 'b.system.bar', 'Int32', 'foo', 'Object[]', 'foo[]'
        $inputList | Format-TypeName -NoBrackets
        | Should -Be $expected
    }

    It 'Pipe: Types as text' {
        # $inputList = 'b.system.bar', 'Int32', 'foo', 'Object[]', 'foo[]'
        $inputList = 'b.system.bar', (23).GetType(), 'System.foo', 'System.Object[]', 'foo[]'
        $expected = '[b.system.bar]', '[Int32]', '[foo]', '[Object[]]', '[foo[]]'
        $inputList | Format-TypeName
        | Should -Be $expected
    }

    # future: mixed type info and strings
}



if ($false -and 'debug sketch to remove') {
    # _FormatCommandInfo-GenericParameterTypeName -Debug -Verbose
    hr 10
    $gcmLs = Get-Command Get-ChildItem
    $inst_paramLs = $gcmLs.Parameters
    $type_paramLs = $gcmLs.Parameters.GetType()

    h1 'Format-TypeName'

    $type_paramLs | Format-TypeName
    hr

    h1 '.GetType()'
    $inst_paramLs.GetType().FullName
    $type_paramLs
    | Select-Object Name, FullName, Namespace, GenericParameterAttributes, GenericParameterPosition, GenericTypeArguments


    # $gcmLs.Parameters.GetType()

    h1 'FullName | Format-TypeName'
    'cat' | Format-TypeName
    $type_paramLs | Format-TypeName

    h1 'type | Format-GenericTypeName'
    hr
    h2 'generic using Format-TypeName'
    $type_paramLs | Format-TypeName
    Label 'Using Format-GenericTypeName'

    hr
    h2 'invoke-RestMethod'

    try {
        Invoke-RestMethod -Uri 'https://httpbin.org/status/500' #|  Out-Null
    } catch {
        $errorRest = $_
        Label 'orig'
        $errorRest, $errorRest.Exception | ForEach-Object { $_.GetType().FullName }
        Label 'FormatTypeName'
        $errorRest, $errorRest.Exception | ForEach-Object {
            $_.GetType()
        } | Format-TypeName
    }



}