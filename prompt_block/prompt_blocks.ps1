


function __prompt_noModuleLoaded {
    @(
        "`n`n"

        $(if (Test-Path variable:/PSDebugContext) {
                '[DBG]🐛> '
            } else {
                ''
            }) + 'Pwsh ' + "`n" + $(Get-Location) + "`n" +
        $(if ($NestedPromptLevel -ge 1) {
                '>>'
            }) + '> '
    ) -join ''
}
function __prompt_usingColorExperiment_v1 {
    @(

        "`n`n"
        $Error.count -gt 0 ? $Error.count : $null
        "`n"
        Get-Location | Write-ConsoleColorZd 'gray40'
        "`n"
    (Get-Location) -split '\\' | ReverseIt | Join-String -Separator ': ' | Write-ConsoleColorZd 'gray60'
        "`n"
        "`nPwsh> "

    ) -join ''
}
function __prompt_usingColorExperiment_v2 {
    @(

        "`n`n"
        if ($Error.count -gt 0) {
            $Error.Count | Write-ConsoleColorZd 'orange'
        }

        "`n"
        # Get-Location | Write-ConsoleColorZd 'gray40'
        # "`n"
        function _theme1 {
            $crumbs = (Get-Location) -split '\\' | ReverseIt
            $joinSep = ': ' | Write-ConsoleColorZd 'gray30' -BackgroundColor 'gray60'
            @(
                $crumbs | Select-Object -First 1 | Write-ConsoleColorZd 'gray85'

                $crumbs | Select-Object -Skip 1 -First 2
                | Write-ConsoleColorZd 'gray65'

                $crumbs | Select-Object -Skip 3
                | Write-ConsoleColorZd 'gray50'
            ) | Join-String -sep $joinSep

            "`n"
            "`nPwsh> "
        }

        function _theme2 {
            $crumbBold = @{
                FG = 'gray30'
                BG = 'gray80'
            }
            $crumbDim = @{
                FG = 'gray30'
                BG = 'gray60'

            }
            $crumbDim2 = @{
                fG = 'gray60'
                BG = 'gray30'
            }
            $crumbs = (Get-Location) -split '\\' | ReverseIt
            $joinSep = ': ' | Write-ConsoleColorZd @crumbBold
            @(
                $crumbs | Select-Object -First 1 | Write-ConsoleColorZd @crumbBold

                $crumbs | Select-Object -Skip 1 -First 2
                | Write-ConsoleColorZd @crumbDim

                $crumbs | Select-Object -Skip 3
                | Write-ConsoleColorZd $crumbDim2
            ) | Join-String -sep $joinSep

            "`n"
            "`nPwsh> "
        }

        if (@($true, $false | Get-Random -Count 1)) {
            _theme2
        } else {
            _theme1
        }
        # randomly pick one?
        # _theme1

    ) -join ''
}
