BeforeAll {
    Import-Module 'Ninmonkey.Console' -Force
}

Describe 'IgnoreText Before/After match' {
    BeforeAll {
        $stdout ??= @{}
        $stdout.ping ??= ping -n 3 -w 10 google.com
    }
    Context '_textIgnoreUntilMatch' {
    }
    Context '_textIgnoreAfterMatch' {

    }
}
