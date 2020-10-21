BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Format-TypeName" {
    It 'String: FileInfo' {
        'System.IO.FileInfo' | Format-TypeName
        | Should -Be 'IO.FileInfo'
    }

    It 'String: FileInfo -WithBrackets' {
        'System.IO.FileInfo' | Format-TypeName -WithBrackets
        | Should -Be '[IO.FileInfo]'
    }

    It 'String: FileInfo -IgnorePrefix "System.IO"' {
        'System.IO.FileInfo' | Format-TypeName -IgnorePrefix 'System.IO'
        | Should -Be 'FileInfo'
    }

    It 'TypeInfo instance: FileInfo' {
        $file = (Get-ChildItem . -Directory | Select-Object -First 1)
        $file.GetType() | Format-TypeName
        | Should -be 'IO.DirectoryInfo'
    }

    It 'TypeInfo instance: FileInfo -WithBrackets' {
        $file = (Get-ChildItem . -Directory | Select-Object -First 1)
        $file.GetType() | Format-TypeName -WithBrackets
        | Should -be '[IO.DirectoryInfo]'
    }

    It 'String: FileInfo -IgnorePrefix "System.IO"' {
        $file = (Get-ChildItem . -Directory | Select-Object -First 1)
        $file.GetType() | Format-TypeName -IgnorePrefix 'System.IO'
        | Should -Be 'DirectoryInfo'
    }

    It 'Pipe: Types as text' {
        # $inputList = 'b.system.bar', 'Int32', 'foo', 'Object[]', 'foo[]'
        $inputList = 'b.system.bar', (23).GetType(), 'System.foo', 'System.Object[]', 'foo[]'
        $expected = 'b.system.bar', 'Int32', 'foo', 'Object[]', 'foo[]'
        $inputList | Format-TypeName
        | Should -Be $expected
    }

    It 'Pipe: Types as text -WithBrackets' {
        # $inputList = 'b.system.bar', 'Int32', 'foo', 'Object[]', 'foo[]'
        $inputList = 'b.system.bar', (23).GetType(), 'System.foo', 'System.Object[]', 'foo[]'
        $expected = '[b.system.bar]', '[Int32]', '[foo]', '[Object[]]', '[foo[]]'
        $inputList | Format-TypeName -WithBrackets
        | Should -Be $expected
    }

    # future: mixed type info and strings
}