#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-WtThemeTest'
        'Invoke-WtThemeTest_basic'
        'Get-WindowsTerminalOption'
    )
    $publicToExport.alias += @(

    )
}

function Get-WindowsTerminalOption {
    <#
    .synopsis
        wrapper for a couple of options
    .notes
    .example
        PS> # get fullpath to current config:
        Get-WindowsTerminalOption ConfigPath

            $Env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json
    .example

        PS> Get-WindowsTerminalOption EnumerateThemeNames

            # names ...
            Nord-3bit-iter2
            One Half Dark
            One Half Light
            Solarized Dark
            Solarized Light
            Tango Dark
            Tango Light
            Vintage
    .example
        safe> # regex theme names
         Get-WindowsTerminalOption SearchThemes tango
         | Ft name, *

            name        background black   blue    brightBlack brightBlue brightCyan
            ----        ---------- -----   ----    ----------- ---------- ----------
            Tango Dark  #000000    #000000 #3465A4 #555753     #729FCF    #34E2E2
            Tango Light #FFFFFF    #000000 #3465A4 #555753     #729FCF    #34E2E2
    #>
    [CmdletBinding()]
    param(
        # which type
        [Parameter(Position = 0, Mandatory)]
        [ValidateSet('EnumerateThemeNames', 'SearchThemes', 'ConfigPath')]
        [String]$Option,

        # Some options take arguments
        [Parameter(Position = 1)]
        [object]$Parameter1
    )

    $configPath = Get-Item "$Env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    switch ($Option) {
        'EnumerateThemeNames' {
            return (Get-Content $configPath | ConvertFrom-Json).schemes.name | Sort-Object -Unique
        }
        'SearchThemes' {
            return (Get-Content $configPath | ConvertFrom-Json).schemes | Where-Object Name -Match $Parameter1
        }
        'ConfigPath' {
            return $ConfigPath
        }
        default {
            'ExpectedOption: ConfigPath, SearchThemes, EnumerateThemeNames'
        }
    }
}

function Invoke-WtThemeTest_basic {
    <#
    .SYNOPSIS
        # randomly choose a single theme, else open all themes in a testing window
        was the initial sketch Without changing settings, view the theme in multiple color schemes
    .notes
        Obsolete unless 'Invoke-WtThemeTest' becomes more complicated

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
    # $themes = @( 'Nin-Nord', 'Dracula', 'Nord-3bit-iter2', 'Nord-3bit-iter2', 'BirdsOfParadise', 'Solarized Dark', 'Nin-Nord', 'Nin-Nord', 'Nin-Nord', 'ninmonkey-darkgrey', 'BirdsOfParadise', 'Nord-3bit-iter2', 'Nin-Nord', 'BirdsOfParadise' )
    $Themes = Get-WindowsTerminalOption -Option EnumerateThemeNames
    $scheme = $themes | Get-Random -Count 1
    $verb = 'split-tab'
    $verb = 'new-tab'
    $window = 'theme-test'
    $profileName = 'pwsh' # '"Pwsh² -Nop"'
    $FirstPass = $true

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
    <#
    .SYNOPSIS
        # randomly choose a single theme, else open all themes in a testing window
        Without changing settings, view the theme in multiple color schemes
    .description
        - does not change profile settings
        - opens in a new window specific for testing, (named window) meaning it
            will not spam your current windows stuff.
    .notes
        runs commands like: #split-pane --profile 'Pwsh² -Nop' --title 'a' -d (gi C:\nin_temp) split-pane --profile 'Pwsh² -Nop' --title 'b'

    .link
        Invoke-WtThemeTest_basic
    #>
    param(
        [switch]$Random,
        [hashtable]$Options = @{}
    )
    $Config = Join-Hashtable -OtherHash $Options -BaseHash @{
        # themes      = @( 'Nin-Nord', 'Dracula', 'Nord-3bit-iter2', 'Nord-3bit-iter2', 'BirdsOfParadise', 'Solarized Dark', 'Nin-Nord', 'Nin-Nord', 'Nin-Nord', 'ninmonkey-darkgrey', 'BirdsOfParadise', 'Nord-3bit-iter2', 'Nin-Nord', 'BirdsOfParadise' )
        themes      = Get-WindowsTerminalOption -Option EnumerateThemeNames
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
        $wtArgs | Join-String -sep ' ' | Write-Host -fore magenta
        & (Get-Command 'wt' -CommandType Application) @wtArgs

        if ($FirstPass) {
            $FirstPass = $false
            Start-Sleep 0.4
        }

    }
}
