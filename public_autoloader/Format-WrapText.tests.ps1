BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'Format-WrapText' {

    Describe 'EnumResolution Should not Fail' {
        BeforeAll {
            $enum_names = & (Get-Module Ninmonkey.Console ) { [WrapStyle] } | Get-EnumInfo | ForEach-Object Name
        }
        It 'Enum <_> Supported' -ForEach $enum_names {
            {
                'sample'
                | wrapText -Style $_ -Argument1 'a' -Argument2 'b'
            } | Should -Not -Throw -Because 'It throws when not implemented'

        }
        It '3 input types' {
            {
                # H1 -bg white -fg purple 'As -PassThru'
                [System.ConsoleColor] | _fmt_enumSummary -PassThru
                [System.ConsoleColor]::Red | _fmt_enumSummary -PassThru
                'System.ConsoleColor' | _fmt_enumSummary -PassThru

                # H1 -bg white -fg purple 'As'
                [System.ConsoleColor] | _fmt_enumSummary
                [System.ConsoleColor]::Red | _fmt_enumSummary
                'System.ConsoleColor' | _fmt_enumSummary
            }
            | Should -Not -Throw
        }
    }
}