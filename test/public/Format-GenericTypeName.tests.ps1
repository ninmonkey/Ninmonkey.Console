BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

<#
system returns

> $typeParam.tostring()
> [string]$typeParam

    System.Collections.Generic.Dictionary`2[System.String,System.Management.Automation.ParameterMetadata]
    System.Collections.Generic.Dictionary[string,System.Management.Automation.ParameterMetadata]

#>
Describe "Format-GenericTypeName" -Tag 'wip' {

    Context 'Testing Powershell itself, to make later assumptions easier.' -Tag 'Optional', 'Pwsh.exe' {
        BeforeAll {
            $objParam = (Get-Command -Name 'Get-ChildItem').Parameters
            $typeParam = $objParam.GetType()
            $typeParam | Format-GenericTypeName
        }

        It 'TypeName using ToString()' {

            $expected = 'System.Collections.Generic.Dictionary[string,System.Management.Automation.ParameterMetadata]'
            # $expected = 'System.Collections.Generic.Dictionary`2[System.String,System.Management.Automation.ParameterMetadata]'
            $expected = 'System.Collections.Generic.Dictionary`2[System.String,System.Management.Automation.ParameterMetadata]'
            $typeParam.tostring() | Should -be $expected
            <#

System.Collections.Generic.Dictionary`2[System.String,System.Management.Automation.ParameterMetadata]
            #>
        }
        It 'TypeName cast as [String]' {
            $expected = 'System.Collections.Generic.Dictionary[string,System.Management.Automation.ParameterMetadata]'
            [string]$typeParam | Should -be $expected
        }
    }

    Context 'Non-Generic Type' {
        It 'adfs' {
            # ensure non-generics on generics fails ?
        }
    }

    Context 'Generic Type from (NameSpace, Name -join)' {
        BeforeAll {
            $l = [list[string]]::new()
            $TypeInfo = $l.GetType()
            $strNameNamespace = $TypeInfo.Namespace, $TypeInfo.Name -Join ''
        }

        It 'Validate Expected Sample Join' {
            $Expected = 'System.Collections.GenericList`1'
            $strNameNamespace | Should -be $Expected
        }
        It 'Format raw string' {
            $strNameNamespace | Format-TypeName
            | Should -be '[GenericList`1]'
        }
        # It ''6
    }

    Context 'Get-Command Results' {
        BeforeAll {
            $objParam = (Get-Command -Name 'Get-ChildItem').Parameters
            $TInfo = $objParam.GetType()
        }

        It 'Test Generic Type instance: NoBrackets' {
            $Expected = 'Dictionary`2[[String], [ParameterMetadata]]'
            $TInfo | Format-GenericTypeName
            | Should -be $Expected
        }

        It 'Test Generic Type instance' {
            $Expected = 'Dictionary`2[[String], [ParameterMetadata]]'
            $TInfo | Format-GenericTypeName -WithBrackets
            | Should -be $Expected
        }


    }

}