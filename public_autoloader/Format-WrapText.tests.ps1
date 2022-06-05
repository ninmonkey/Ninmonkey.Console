BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'Format-WrapText' {
    Describe 'EnumResolution Should not Fail' {
        {
            # H1 -bg white -fg purple 'As -PassThru'
            [System.ConsoleColor] | _fmt_enumSummary -PassThru
            [System.ConsoleColor]::Red | _fmt_enumSummary -PassThru
            'System.ConsoleColor' | _fmt_enumSummary -PassThru

            # H1 -bg white -fg purple 'As'
            [System.ConsoleColor] | _fmt_enumSummary
            [System.ConsoleColor]::Red | _fmt_enumSummary
            'System.ConsoleColor' | _fmt_enumSummary
        } | Should -Throw
    }
}