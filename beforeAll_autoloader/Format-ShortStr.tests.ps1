BeforeAll {
    Import-Module Ninmonkey.Console -Force *>$null
}

Describe 'Format-ShortString' {


    Context 'VisualExamples' {
        It 'short' -Tag 'WriteHost', 'VisualTest', 'UsingAnsiEscapes' { @(
                'z'..'a' -join '_'
                'z'..'a' -join '_' | shortStr
                'z'..'a' -join '_' | shortStr -HeadCount 3 -TailCount 3 -Options @{ AlwaysQuoteInner = $false }
                'z'..'a' -join '_' | shortStr -HeadCount 3 -TailCount 3 -Options @{ AlwaysQuoteInner = $true }
                $true | Should -Be $True
                # Set-ItResult -Skipped -Because 'Visual only example'
            ) }
        It 'Visual Demo' -Tag 'WriteHost', 'VisualTest', 'UsingAnsiEscapes', 'VeryVerbose' {
            @(
                'z'..'a' -join '_'
                'z'..'a' -join '_' | shortStr
                'z'..'a' -join '_' | shortStr -HeadCount 3 -TailCount 3 -Options @{ AlwaysQuoteInner = $false }
                'z'..'a' -join '_' | shortStr -HeadCount 3 -TailCount 3 -Options @{ AlwaysQuoteInner = $true }
                Get-Process | s -First 20 | Join-String -sep (hr 1) -Property {
                    $_.CommandLine | shortStr -HeadCount 90 -TailCount 40 }
            ) | Write-Host
            $true | Should -Be $True
            # Set-ItResult -Skipped -Because 'Visual only example'

        }
        It 'more' -Tag 'WriteHost', 'VisualTest', 'UsingAnsiEscapes', 'VeryVerbose' {
            @(
                'z'..'a' -join '_'
                'z'..'a' -join '_' | shortStr
                'z'..'a' -join '_' | shortStr -HeadCount 3 -TailCount 3
                $Color = @{
                    Fg    = $PSStyle.Foreground.FromRgb('#c6b8e9')
                    FgDim = $PSStyle.Foreground.FromRgb('#dbcfff')

                    Reset = $PSStyle.Reset
                }

                Get-Process
                | Sort-Object Name -Unique
                | ForEach-Object name
                | shortStr -Options @{
                    AlwaysQuoteInner = $False ;
                    TotalPrefix      = $Color.Fg;
                    TotalSuffix      = $Color.Reset;
                    Separator        = @(
                        $Color.Reset
                        $Color.FgDim
                        '...'
                        $Color.Reset
                        $Color.Fg
                    ) -join ''
                }
            ) | Write-Host
            $true | Should -Be $True
            # Set-ItResult -Skipped -Because 'Visual only example'

        }
    }
}