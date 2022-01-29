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
    Context 'Generics' -pending {
        BeforeAll {
            $ExampleExistingUrls = @(
                @{
                    Label = 'List<T> Constructors'
                    Url   = 'https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1.-ctor?view=net-6.0'
                    Main  = 'list-1.-ctor'
                }
                @{
                    Label = 'List<T> Class'
                    Url   = 'https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1?view=net-6.0'
                    Diff  = '-'
                    Main  = 'list-1'
                }
            )
        }
        <#
        default outputs:

        https://docs.microsoft.com/en-us/dotnet/api/System.Collections.Generic.List`1
        https://docs.microsoft.com/en-us/dotnet/api/System.Collections.Generic.List`1[[System.Int32, System.Private.CoreLib, Version=6.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]
        https://docs.microsoft.com/en-us/dotnet/api/System.Collections.Generic.List`1[[System.Object, System.Private.CoreLib, Version=6.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]
        https://docs.microsoft.com/en-us/dotnet/api/System.Int32[]
        https://docs.microsoft.com/en-us/dotnet/api/System.Object[]
        #>
        # [list[int]]
        # [list[object]]
        # [object[]]
        # [int[]]
        # ) | HelpFromType -PassThru


        It 'Basic' -Foreach -Pending @(
            @{ InputObject = ''
                Expected   = ''
            }
            $false | Should -Be $true
        )

        $PSSamplePath | HelpFromType -PassThru
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
