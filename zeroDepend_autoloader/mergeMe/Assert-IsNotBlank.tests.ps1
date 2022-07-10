#Requires -Version 7

BeforeAll {
    # Import-Module mintils -Force
    . (Get-Item (Join-Path $PSScriptRoot) 'Assert-IsNotBlank.ps1')
}


Describe 'Assert\Where\Test -IsNotBlank' {
    Describe 'Where-IsNotBlank' {
        it 'Basics' {
            $Samples =  'foo', $null, '  ', "`n`t", "`t1"
            $Expected = 'foo', "`t1"

            $Samples
            | mintils\?IsNotBlank # | mintils\Where-IsNotBlank
            | Should -BeExactly $Expected -Because 'Manually created data'
        }
    }

    Describe 'Assert-IsNotBlank' {
        Context 'Test returns bool' {

            it 'Test-IsNotBlank does not throw' {
                { mintils\Test-IsNotBlank " `n " }
                | Should -not -Throw
            }
            It 'basic blank' {

                mintils\Test-IsNotBlank " `n "
                | Should -be $false
           }

        }

    }

}
