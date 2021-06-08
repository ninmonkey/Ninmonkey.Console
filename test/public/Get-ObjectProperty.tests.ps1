BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Get-ObjectProperty' {
    BeforeAll {
        $Sample = @{
            'StringList4' = 0..4 | ForEach-Object { [string]$_ }
        }
        #     $Samples = @{
        #         Num        = 3
        #         NumString  = 3, 'text'
        #         NumListNum = 4, ('a', 'b'), 9
        #         HashEmpty  = @{}
        #         ArrayEmpty = @()
        #         ListEmpty  = [list[string]]::new()
        #     }
    }
    It 'Limit total input objects: 2' {
        $filtered = $Sample['StringList4'] | Get-ObjectProperty -Limit 2
        $filtered.count | Should -Be 2
    }
    It 'Limit total input objects: 1' {
        $filtered = $Sample['StringList4'] | Get-ObjectProperty -Limit 1
        $filtered.count | Should -Be 1
    }

    Context -Name 'Folder Instance' {
        # for linux use $home instead?
        It 'Directory Props' -Tag 'OS Windows' { # should not matter
            $Directory = Get-Item .
            $expected = $Directory.psobject.properties.name | Sort-Object

            $Directory | Get-ObjectProperty | ForEach-Object Name | Sort-Object
            | Should -Be $expected
        }
    }
    <#
    Context -Name 'Profile Properties' {
        BeforeAll {
            $ExpectedProps = 'Length', 'AllUsersAllHosts', 'AllUsersCurrentHost', 'CurrentUserAllHosts', 'CurrentUserCurrentHost'
            | Sort-Object
        }
        It 'Base Case' {
            $profile.psobject.properties.Name | Sort-Object
            | Should -Be $ExpectedProps
        }

        It 'Prop No Type Filter' {
            $profile | Get-ObjectProperty | Sort-Object | Should -Be $ExpectedProps -Because 'this fails specifically on string because it is note properties, not actual properties? or piping then .psobject.properties isn''t working'
        }
    }
    #>

}
