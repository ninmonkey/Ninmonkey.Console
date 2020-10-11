# $here = Split-Path -Parent $MyInvocation.MyCommand.Path
# $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.tests\.', '.'
# . "$here\$sut"

# Describe "Write-AnsiHyperlink" {
#     It "does something useful" {
#         $true | Should -Be $true
#     }
#     It "other" {
#         $true | Should -be $false
#     }
# }



$urlExcel = 'https://support.microsoft.com/en-us/office/formulas-and-functions-294d9486-b332-48ed-b489-abe7d0f9eda9?ui=en-US&rs=en-US&ad=US#ID0EAABAAA=More_functions'

Label 'Write-AnsiHyperlink [Defaults]'
Write-AnsiHyperlink -Uri $urlExcel 'Excel Functions'
# | Should -Be '<https://support.microsoft.com/en-us/office/formulas-and-functions-294d9486-b332-48ed-b489-abe7d0f9eda9?ui=en-US&rs=en-US&ad=US#ID0EAABAAA=More_functions>'

Label 'Write-AnsiHyperlink -NoAnsi'
Write-AnsiHyperlink -Uri $urlExcel 'Excel Functions' -NoAnsi

Label 'Write-AnsiHyperlink -AsMarkdown'
Write-AnsiHyperlink -Uri $urlExcel 'Excel Functions' -AsMarkdown

Label 'Write-AnsiHyperlink -NoAnsi -AsMarkdown'
Write-AnsiHyperlink -Uri $urlExcel 'Excel Functions' -AsMarkdown -NoAnsi
