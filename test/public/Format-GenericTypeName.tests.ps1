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
Describe "Format-GenericTypeName" {
    BeforeAll {
        $objParam = (Get-Command -Name 'Get-ChildItem').Parameters
        $typeParam = $objParam.GetType()
        $typeParam | Format-GenericTypeName -WithBrackets
    }

    Context 'Powershell Assumptions for tests below' {

        It 'TypeName using ToString()' {
            $expected = 'System.Collections.Generic.Dictionary`2[System.String,System.Management.Automation.ParameterMetadata]'
            $typeParam.tostring() | Should -be $expected

        }
    }

    Context 'Regular Type' {
        It 'Format GenericType Commandlet Param' {
            $true | Should -Be $true
        }
    }

    Context 'Generic Type' {

    }

    # hashtable type would it fit in any ?

    5 }


# if ($false -and 'genericTypeName only') {
#     $gcmLs = Get-Command Get-ChildItem
#     $inst_paramLs = $gcmLs.Parameters
#     $type_paramLs = $gcmLs.Parameters.GetType()
#     $type_paramLs | Format-GenericTypeName -WithBrackets

#     if ($false -and 'RunVerbose') {
#         h1 '.NameSpace + .Name'
#         $type_paramLs.Namespace, $type_paramLs.Name -join ''
#         h1 '.FullName'
#         $type_paramLs.FullName
#         h1 '| Format-Table'
#         $type_paramLs | Format-Table
#         h1 '| Format-TypeName'
#         $type_paramLs | Format-TypeName -WithBrackets
#         h1 '| Format-GenericTypeName'
#         $type_paramLs | Format-GenericTypeName -WithBrackets
#     }
# }