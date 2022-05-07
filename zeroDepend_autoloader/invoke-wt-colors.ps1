﻿#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-WtThemeTest'
        'ZD-Invoke-WtThemeTest'
    )
    $publicToExport.alias += @(

    )
}



function ZD-Invoke-WtThemeTest {
    # randomly choose a single theme, else open all themes in a testing window
    <#
    .SYNOPSIS
        Without changing settings, view the theme in multiple color schemes
    .notes
        runs commands like: #split-pane --profile 'Pwsh² -Nop' --title 'a' -d (gi C:\nin_temp) split-pane --profile 'Pwsh² -Nop' --title 'b'
    .example
        PS> zd-Invoke-WtThemeTest -Random  # run twice
        PS> zd-Invoke-WtThemeTest -Random
    .example
        PS> zd-Invoke-WtThemeTest -Random  # show all themes
    #>
    param(
        [switch]$Random
    )
    $themes = @( 'Nin-Nord', 'Dracula', 'Nord-3bit-iter2', 'Nord-3bit-iter2', 'BirdsOfParadise', 'Solarized Dark', 'Nin-Nord', 'Nin-Nord', 'Nin-Nord', 'ninmonkey-darkgrey', 'BirdsOfParadise', 'Nord-3bit-iter2', 'Nin-Nord', 'BirdsOfParadise' )
    $scheme = $themes | Get-Random -Count 1
    $verb = 'split-tab'
    $verb = 'new-tab'
    $window = 'theme-test'
    $profileName = 'pwsh' # '"Pwsh² -Nop"'
    $FirstPass = $true

    # make sure one instance exists to prevent spam
    & (Get-Command 'wt' -CommandType Application) -w $Window --title 'no-args'
    Start-Sleep 0.3

    if ($Random) {
        $themes = $themes | Get-Random -Count 1
    }
    foreach ($scheme in $themes) {
        "invoke: wt -w $window $verb --title `"$scheme`" --profile $ProfileName --colorScheme `"$scheme`"" | Write-Host -fore magenta
        & (Get-Command 'wt' -CommandType Application) -w $window $verb --title "`"$scheme`"" --profile "`"$ProfileName`"" --colorScheme "`"$scheme`""
        if ($FirstPass) {
            # ensure named window exists, before invoking
            $FirstPass = $false
            Start-Sleep 0.4
        }

    }
}

function Invoke-WtThemeTest {
    # randomly choose a single theme, else open all themes in a testing window
    <#
    .SYNOPSIS
        Without changing settings, view the theme in multiple color schemes
    .description
        - does not change profile settings
        - opens in a new window specific for testing, meaning it
            will not spam your current stuff.
    .notes
        runs commands like: #split-pane --profile 'Pwsh² -Nop' --title 'a' -d (gi C:\nin_temp) split-pane --profile 'Pwsh² -Nop' --title 'b'

    .link
        ZD-Invoke-WtThemeTest
    #>
    param(
        [switch]$Random,
        [hashtable]$Options = @{}
    )
    $Config = Join-Hashtable -OtherHash $Options -BaseHash @{
        themes      = @( 'Nin-Nord', 'Dracula', 'Nord-3bit-iter2', 'Nord-3bit-iter2', 'BirdsOfParadise', 'Solarized Dark', 'Nin-Nord', 'Nin-Nord', 'Nin-Nord', 'ninmonkey-darkgrey', 'BirdsOfParadise', 'Nord-3bit-iter2', 'Nin-Nord', 'BirdsOfParadise' )
        verb        = 'new-tab' # 'split-tab'
        window      = 'theme-test'
        profileName = 'pwsh' #'Pwsh² -Nop'
    }
    $FirstPass = $true

    if ($Random) {
        $themes = $Config.themes | Get-Random -Count 1
    } else {
        $themes = $Config.themes
    }

    # make sure one instance exists to prevent spam
    # & (Get-Command 'wt' -CommandType Application) -w $Config.Window --title 'no-args'
    # Start-Sleep 0.3

    foreach ($scheme in $themes) {
        $wtArgs = @(
            '-w'
            $config.window
            $config.verb
            '--title'

            $scheme | Join-String -DoubleQuote
            '--profile'

            $config.ProfileName | Join-String -DoubleQuote
            '--colorScheme'

            $scheme
            | Join-String -DoubleQuote
        )
        $wtArgs -join ' ' | Write-Host -fore magenta
        $wtArgs | Join-String -sep ' ' | Write-Host -fore magenta
        & (Get-Command 'wt' -CommandType Application) @wtArgs

        if ($FirstPass) {
            $FirstPass = $false
            Start-Sleep 0.4
        }

    }
}