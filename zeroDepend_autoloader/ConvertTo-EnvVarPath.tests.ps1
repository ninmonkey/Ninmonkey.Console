
BeforeAll {
    . (Join-Path $PSScriptRoot 'ConvertTo-EnvVarPathPath.ps1' | Get-Item -ea stop)
}

Describe 'ConvertTo-EnvVar-paths' {
    Describe 'ConvertFrom' {
        BeforeAll {
            $user_asLiteralVar = '$Env:USERPROFILE\Documents'
            $user_asLiteralVar2 = '%USERPROFILE%\Documents'
            $user_asItem = Get-Item $user_
        }

        It 'wip' {
            $True | Should -Be $False
            # SetIt-Result 'wip' -
            # $Env:UserProfile
        }
    }
    Describe 'ConvertTo' {

    }

}
