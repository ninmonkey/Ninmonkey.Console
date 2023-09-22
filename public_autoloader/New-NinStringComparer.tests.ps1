BeforeAll {
    # walrus sugar to cancel verbose/warning/info streams yet -passthru print module version
    ( $load = Import-Module Ninmonkey.Console -Force -PassThru ) *>$Null
    $load | ft -auto | Out-Host
}

Describe 'New-NinStringComparer' {
    It '<Kind> of <Left> and <Right>' -foreach @(
        @{
            Left = 'a'
            Right = 'A'
            Kind = 'OrdinalIgnoreCase'
            ExpectResult = 0
        }
        @{
            Left = 'a'
            Right = 'A'
            Kind = 'OrdinalIgnoreCase', 'CurrentCulture'
            ExpectResult = 0, -1
        }
            # New-NinStringComparer -LeftInput 'a' -RightInput 'A' -StringComparerKind OrdinalIgnoreCase | % Result | Should -be 0

    ) {
        New-NinStringComparer -Left $Left -Right  $Right -StringComparerKind $Kind
            | % Result | Should -be $ExpectResult

    }
    it 'Manual Implements Test' {
        $cmp = New-NinstringComparer -PassThru -StringComparerKind InvariantCulture
        $cmp.GetType().ImplementedInterfaces.name -contains 'IEqualityComparer'
            | Should -be $True

    }
    # $out.GetType().ImplementedInterfaces | Join-String -sep ', ' {
    #     $_.Namespace, $_.Name -join '.'  -replace 'System\.', ''
    # }
    # It 'hardcoded' {
    #     New-NinStringComparer -LeftInput 'a' -RightInput 'A' -StringComparerKind OrdinalIgnoreCase
    #     $false | Should -Be $True
    # }
}
