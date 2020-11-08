BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

<#

if ($true) {
    # need to test: should test
    # 'System.System.System' | Format-TypeName -IgnorePrefix 'System' -ea Continue
    'system.text'.GetType() | Format-TypeName
}
#>

Describe "Format-TypeName" -Tag 'wip' {
    It 'String: FileInfo' {
        'System.IO.FileInfo' | Format-TypeName
        | Should -Be '[IO.FileInfo]'
    }

    It 'String: FileInfo' {
        'System.IO.FileInfo' | Format-TypeName -NoBrackets
        | Should -Be 'IO.FileInfo'
    }

    It 'String: FileInfo -IgnorePrefix "System.IO" -NoBrackets' {
        'System.IO.FileInfo' | Format-TypeName -IgnorePrefix 'System.IO' -NoBrackets
        | Should -Be 'FileInfo'
    }

    It 'TypeInfo instance: FileInfo' {
        $file = (Get-ChildItem . -Directory | Select-Object -First 1)
        $file.GetType() | Format-TypeName
        | Should -be '[IO.DirectoryInfo]'
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

    Context 'Should Forward Generics' {
        BeforeAll {
            $items = [list[string]]::new()
            $itemType = $items.GetType()
            $expectedTypeFormat = '[List`1[String]]'
        }

        It 'Should Forward to Format-GenericTypeName' {
            $itemType | Format-TypeName
            | Should -Be $expectedTypeFormat
        }

        It 'Should Not Forward' {
            $itemType | Format-GenericTypeName
            | Should -Be $expectedTypeFormat
        }
    }
}
