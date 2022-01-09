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
    Context 'ManuallyCreatedUrls' -Tag 'manual' {
        $Text = '[Math]'
        $Expected = @(

        )

        It 'TypeInfo' -Pending {
            '[Math]'
            | HelpFromType -PassThru | Should -BeIn @(
                'https://docs.microsoft.com/en-us/dotnet/api/system.math'
            )


        }
        It 'MethodInfo -> on TypeInfo' -Pending {
            <#
                Maybe help in
                [math] | fm round

            #>
            [math]::Round
            | HelpFromType -PassThru | Should -BeIn @(
                'https://docs.microsoft.com/en-us/dotnet/api/system.math.round'
            )

        }
        It 'Type: Field on static class' -Pending {
            [Math]::pi
            | HelpFromType -PassThru
            | shoudld -be 'https://docs.microsoft.com/en-us/dotnet/api/system.math.pi'
        }
        It 'Env Var type' -Pending {
            Get-ChildItem env: | s -first 1
            | HelpFromType
            | Should -BeIn @(
                'System.Collections.DictionaryEntry'
            ) -Because 'maybe'




            <#
                PSTypeNames:
                    'System.Collections.DictionaryEntry'
                    'System.Object'
                    'System.ValueType'
                #>
        }


        # '[Math]'
        # | HelpFromType -PassThru | Should -BeIn @(

        #     https://docs.microsoft.com/en-us/dotnet/api/system.math.round
        # }
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
    It 'Throttle Duplicates' {
        $files = Get-ChildItem ~
        $expected = $files | Get-Unique -OnType

        $files
        | HelpFromType -PassThru
        | len | Should -Be $expected
    }
}
