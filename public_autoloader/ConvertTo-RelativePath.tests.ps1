BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'ConvertTo-RelativePath' {
    It 'from IO' -Pending {
        $true | Should -Be $false

    }
    It 'from fullname text' -Pending {
        $true | Should -Be $false
    }

    It 'from partial name text' -Pending {

        $true | Should -Be $false
    }
    Describe 'Text Vs Object' {
        It 'With Color' {
            {
                newestItem🔎 -ItemType Pwsh
                | First 4
                | To->RelativePath
            } | Should -Not -Throw
        }
        It 'As Object' {
            {
                Get-ChildItem
                | First 4
                | To->RelativePath
            } | Should -Not -Throw
        }
    }
    Describe 'Hard-coded Dotnet calls' {
        BeforeAll {
            $target = Get-Item $env:Nin_Dotfiles
            $relativeTo = Get-Item $env:USERPROFILE
            $expectedText = 'SkyDrive\Documents\2021\dotfiles_git'
        }
        It 'Baseline True Case' {
            $result = [io.path]::GetRelativePath($relativeTo, $target)
            $result | Should -Be $expectedText
        }

        It 'Test True' {
            $target | ConvertTo-RelativePath -BasePath $relativeTo
            | Should -Be $expectedText
        }
    }
}
