BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-ObjectType" {
    BeforeAll {
        $Samples = @{
            Num        = 3
            NumString  = 3, 'text'
            NumListNum = 4, ('a', 'b'), 9
            HashEmpty  = @{}
            ArrayEmpty = @()
            ListEmpty  = [list[string]]::new()
        }
    }

    Context 'Input from Pipeline' {
        Context 'SingleInput' {
            It 'PSTypeNames' {
                $Expected = (1).pstypenames
                $Result = (1) | TypeOf -PassThru
                $Result | Should -Be $Expected
            }
        }
        Context 'Multiple Input' {
            It 'Number, Array' {
                $sample = 5, ('a', 'b')
                $Expected = $sample | ForEach-Object { , $_.pstypenames }


                # $Result = 5, ('a', 'b') | TypeOf -PassThru
            }
        }

        Context 'Format Mode' {
            Context 'Test Default' {
                It 'Default is PSTypeNames' {
                    ('A', 4 | TypeOf )
                    | Should -Be ('A', 4 | TypeOf PSTypeNames)
                }
                It 'PassThru returns a TypeInfo instance' {
                    $result = 'A', 4 | TypeOf GetType -PassThru
                    $result[0] | Should -BeOfType 'type'
                    $result[1] | Should -BeOfType 'type'
                }
                # It 'd' {
                #     (('A', 4 | TypeOf GetType -PassThru)[0]).Name
                #     | Should -BeOfType [string]

                #     (('A', 4 | TypeOf GetType -PassThru)[1]).Name
                #     | Should -BeOfType [string]
                # }

                # 'A', 4 | TypeOf PSTypeNames
                # 'A', 4 | TypeOf PSTypeNames

                # hr
                # 'A', 4 | TypeOf
                # hr
                # 'A', 4 | TypeOf GetType


            }
        }
        Context 'Text Formatting' {
            It 'a' {
                $Sample = 'A', 4
                $Expected = @(
                    'String, Object'
                    'Int32, ValueType, Object'
                ) -join "`n"
                $Expected = $Expected.Trim()

                $resultStdout = ($sample | TypeOf PSTypeNames  | Out-String) -join "`n"
                # $resultStdout | Should -Be $Expected

                # failure was from a cr vs newline
                $Expected = $Expected.Trim() -split '\r?\n' -join "`n"
                $resultStdout = $resultStdout.Trim() -split '\r?\n' -join "`n"
                $resultStdout | Should -be $Expected
                # ($sample | TypeOf PSTypeNames  | Out-String)


                # ($t -join "`n") -eq $Expected

                # $Output = $Sample | TypeOf


            }
        }
    }
}



# $expected = [int].pstypenames | Format-TypeName
# $expected = [int] | Format-TypeName
# 4 | TypeOf -PassThru | Should -Be $expected
# It 'test_NotCreatedTests' {
#     # $true | Should -Be $False -Because 'Tests not written yet'

#     'sdf' | TypeOf | Format-List
#     'sdf' | TypeOf -All | Format-List
#     # c:\Users\cppmo_000\Docum
#     'sdf' | TypeOf -All | Format-List
#     'sdf' | TypeOf
#     'sdf' | TypeOf -All
#     'a', 2 | TypeOf -All
#     ('a', 2) | TypeOf -All
#     ('a', 2) | TypeOf -All
#     , ('a', 2) | TypeOf -All
# }
