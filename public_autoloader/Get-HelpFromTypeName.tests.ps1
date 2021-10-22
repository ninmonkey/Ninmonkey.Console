BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'Get-HelpFromTypeName' {
    BeforeAll {
        $Url = @{
            'TimeSpan' = 'https://docs.microsoft.com/en-us/dotnet/api/System.TimeSpan'
            'DateTime' = 'https://docs.microsoft.com/en-us/dotnet/api/System.DateTime'
        }
    }
    It 'From String' {
        'System.TimeSpan' | Get-HelpFromTypeName -PassThru
        | Should -Be $Url.TimeSpan
    }
    It 'From Instance list' {
        $Expected = @(
            $url.TimeSpan
            $url.DateTime
        )

        $query = @(
            [datetime]::Now
            [timespan]::new(0)
        ) | HelpFromType -PassThru

        $query | Should -Contain $url.TimeSpan
        $query | Should -Contain $url.DateTime
    }
}