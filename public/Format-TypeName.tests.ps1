BeforeAll {
    # . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
    Import-Module Ninmonkey.Console -Force
}

<#

if ($true) {
    # need to test: should test
    # 'System.System.System' | Format-TypeName -IgnorePrefix 'System' -ea Continue
    'system.text'.GetType() | Format-TypeName
}
#>
InModuleScope 'Ninmonkey.Console' {
    Describe '_writeTypeNameString' {
        
        Describe 'Color' -Tag 'Ansi', 'Color' {
            Context 'Raw Strings Type' {
                It 'Default' {
                    _writeTypeNameString 'Foo' | Should -Be 'Foo'
                }    
                It 'Bracket' {
                    _writeTypeNameString 'Foo' -WithBrackets | Should -Be '[Foo]'
                }
            }
        }
        Describe 'NoColor' -Tag 'NO_COLOR' {
            Context 'Raw Strings Type' {
                It 'Default' {
                    _writeTypeNameString 'Foo' | Should -Be 'Foo'
                }    
                It 'Bracket' {
                    _writeTypeNameString 'Foo' -WithBrackets | Should -Be '[Foo]'
                }
            }
            Context 'Real Object FullNames' {
                BeforeEach {
                    $Sample = @{
                        File = Get-Item .
                    }                
                }
                It 'File: -Bracket <WithBrackets> is <Expected>' -Foreach @(
                    @{
                        Expected = 'System.IO.DirectoryInfo' ; WithBrackets = $false
                    }
                    @{
                        Expected = '[System.IO.DirectoryInfo]' ; WithBrackets = $true
                    }
                ) {
                    $Name = $Sample.File.GetType().FullName                    
                    _writeTypeNameString -TypeNameString $Name -WithBrackets:$WithBrackets
                    | Should -Be $Expected
                }
            }
        }
    }
}


Describe 'Format-TypeName' -Tag 'wip' {
    Describe 'Generic Types' {
        It 'Non-Instance of Generic from ClassExplorer' {

        }
    }

    It 'ComplexType DataDriven Test' {
        $Expected = 'Func`2[String, Object]'
        (Get-PSReadLineOption).AddToHistoryHandler | Format-TypeName
        | Should -Be $Expected

        (Get-PSReadLineOption).AddToHistoryHandler.GetType() | Format-TypeName
        | Should -Be $Expected

        (Get-PSReadLineOption).AddToHistoryHandler.GetType().FullName | Format-TypeName
        | Should -Be $Expected
    }

    <#
        a simple..ToString() returns:

            System.Func`2[System.String,System.Object]

        or (Get-PSReadLineOption).AddToHistoryHandler.GetType().ToString() -as 'type' | Format-TypeName

            Func`2[String, Object]
        #>
    It 'FirstEasy' {
        $Sample = 'system.io.fileinfo'
        $sample | ForEach-Object { $_ -as 'type' } | Format-TypeName -Brackets
    }
    It 'AutoConvert Inputs' {
        $Sample = 'system.io.fileinfo'
        $res1 = $sample | Format-TypeName -Brackets
        $res2 = $sample | ForEach-Object { $_ -as 'type' } | Format-TypeName -Brackets
        $res1 | Should -Be $res2 -Because 'Strings should auto-coerce to type instances'
    }
    It 'ads' {
        $Sample = 'System.Func`2[[System.String, System.Private.CoreLib, Version=5.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e],[System.Object, System.Private.CoreLib, Version=5.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]'


        $Sample | Format-TypeName
        | Should -Be 'Func`2[String, Object]'
        # or verbosely: 'System.Func`2[System.String,System.Object]'
    }
    Describe 'IgnorePrefix' {

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
            | Should -Be '[IO.DirectoryInfo]'
        }

        It 'TypeInfo instance: FileInfo' {
            $file = (Get-ChildItem . -Directory | Select-Object -First 1)
            $file.GetType() | Format-TypeName
            | Should -Be '[IO.DirectoryInfo]'
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
    }

    Context 'GenericsWithNestedClass: NYI' -Tag 'wip', 'nyi' {
        It 'Nested Generic from String' {
            $StringGenericTypeName = 'System.Collections.Generic.Dictionary`2+KeyCollection[[System.String], [System.Management.Automation.ParameterMetadata]]'
            $Expected = '[Dictionary`2+KeyCollection[[System.String], [System.Management.Automation.ParameterMetadata]]]'
            $StringGenericTypeName | Format-TypeName
            | Should -Be $Expected
        }
        It 'Nested Generic from [Type] instance' {
            $StringGenericTypeName = 'System.Collections.Generic.Dictionary`2+KeyCollection[[System.String], [System.Management.Automation.ParameterMetadata]]'
            # $Expected = '[Dictionary`2+KeyCollection[[System.String], [System.Management.Automation.ParameterMetadata]]]'
            $ExpectedFail = 'KeyCollection[[String], [ParameterMetadata]]'
            $StringGenericTypeName -as 'Type' | Format-TypeName
            | Should -Not -Be $ExpectedFail
        }
    }
    Context 'Generics with Full Assembly Name from [String]' -Tag 'wip', 'nyi' {
        It 'Could Fail' {
            $StringGenericTypeName = 'System.Collections.Generic.IEqualityComparer`1[[System.String, System.Private.CoreLib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]'
            $CurrentResult = 'IEqualityComparer`1[[String]]'
            $StringGenericTypeName -as 'type' | Format-TypeName
            | Should -Not -Be 'IEqualityComparer`1[[String]]'
        }

    }
    Context 'Should Forward Generics' {
        BeforeAll {
            $items = [list[string]]::new()
            $itemType = $items.GetType()
            $expectedTypeFormat = 'List`1[[String]]'
            $expectedValidFormats = @(
                'List`1[[String]]'
                '[List[string]]'
                [List`1[String]]
                [list[String]]
            )
        }
        It 'From Generic List instance' {
            [Collections.Generic.list[string]] | Format-TypeName | Should -BeIn $expectedValidFormats
        }

        It 'Basic Generic from typeinstance' {
            $SampleType = [System.Collections.ObjectModel.ReadOnlyCollection`1[System.Management.Automation.ExperimentalFeature]]
            $validAnswers = @(
                [Collections.ObjectModel.ReadOnlyCollection`1[ExperimentalFeature]]
                [ReadOnlyCollection`1[ExperimentalFeature]]

            )
            $SampleType | Format-TypeName -Brackets | Should -BeIn $validAnswers
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
