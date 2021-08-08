# if ($True) {
#     Import-Module Ninmonkey.Console -Force *>&1 | Out-Null
# } else {
#     # . (Get-Item -ea stop 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\public\Write-ConsoleText.ps1')
# }
# Some tests are visual, or not Pester worthy
# This file is a scratchboard
Import-Module Ninmonkey.Console -Force -ea stop

# H1 'quick test'
$ConfigTest = @{
    'write-color'  = $false
    'RandomTables' = $True
    'GetCommand'   = $false
}
# $ConfigTest | Format-HashTable -Title 'Config'

if ( $ConfigTest.'write-color' ) {
    Write-ConsoleText -Object 'hi world' -Fg blue | ForEach-Object tostring
    # Write-ConsoleText 'green' -fg green
    @(
        Write-ConsoleText -Object 'hi world' -ForegroundColor red

        @(
            Write-ConsoleText -Object 'blue' -ForegroundColor red

        )


        H1 'part1'
        Get-Gradient '#132454' '#de3ddd' -Width 5
        | Join-String {
            $_.RGB, $_.X11ColorName -join ''
            | New-Text -fg $_
        } '    '

        H1 'try table'
        Get-Gradient '#de3ddd' '#132454'  -Width 5
        | Join-String {
            $_.RGB, $_.X11ColorName -join ''
            | New-Text -fg $_
        } -sep ' | ' -op '| ' -os ' | '
        Get-ChildItem fg: | Get-Random -Count 5
        | Join-String {
            $_.RGB, $_.X11ColorName -join ''
            | New-Text -fg $_
        } -sep ' | ' -op '| ' -os ' | ' -FormatString '{0}'


    ) | ForEach-Object ToString
    # # Write-ConsoleText -
    # @(
    #     Write-ConsoleText 'green' -fg green
    #     Write-ConsoleText 'red' -fg orange
    # ) -join ', '
}

if ( $ConfigTest.'RandomTables' ) {
    # Write-ConsoleText 'green' -fg green
    function _randomRow_FormatStrPadLeft {
        param($count = 3)

        Get-ChildItem fg: | Get-Random -Count $count
        | Join-String {
            $_.RGB, $_.X11ColorName
            | Join-String -Separator ': ' -FormatString '{0,-15}'
            # | ForEach-Object { $_.padLeft(14) }
            | New-Text -fg $_
        } -sep ' | ' -op '| ' -os ' | '
    }
    function _randomRow_StrPadLeft {

        Get-ChildItem fg: | Get-Random -Count 5
        | Join-String {
            $_.RGB, $_.X11ColorName
            | Join-String -Separator ': '
            | ForEach-Object { $_.padLeft(30) }
            | New-Text -fg $_

        } -sep ' | ' -op '| ' -os ' | ' -FormatString '{0,-30}'
    }

    # Write-ConsoleText 'green' -fg green
    function _randomRow_SizedCols {
        param($count = 3)

        Get-ChildItem fg: | Get-Random -Count $count
        | Join-String {
            $_.RGB #, $_.X11ColorName
            | Join-String -Separator ': ' -FormatString '{0,14}'
            # | ForEach-Object { $_.padLeft(14) }
            | New-Text -fg $_
        } -sep ' | ' -op '| ' -os ' | '

    }
    function _randomTable_Autosized {
        param($numCols = 3)
        [object[]]$table = @(
            , @(
                Get-ChildItem fg: | Get-Random -Count $numCols
                | Select-Object -Property 'RGB', 'X11ColorName'
            )
            , @(
                Get-ChildItem fg: | Get-Random -Count $numCols
                | Select-Object -Property 'RGB', 'X11ColorName'
            )
            , @(
                Get-ChildItem fg: | Get-Random -Count $numCols
                | Select-Object -Property 'RGB', 'X11ColorName'
            )
        )
        $colNames = 'rgb', 'X11ColorName'
        # $Table | ConvertTo-Json

        # $colors = Get-ChildItem fg: | Get-Random -Count $count
        $maxWidth_col1 = $Table | Measure-Object -Property { $_.rgb.ToString().Length } -Maximum | ForEach-Object Maximum
        $maxWidth_col1 = $Table.rgb | Measure-Object -Property { $_.ToString().Length } -Maximum | ForEach-Object Maximum
        $maxWidth_col2 = $Table.x11colorname | Measure-Object -Property { $_.ToString().Length } -Maximum | ForEach-Object Maximum

        # or same:
        $maxWidth_col1 = $table.($colNames[0]) | Measure-Object -Property { $_.ToString().Length } -Maximum | ForEach-Object Maximum
        $maxWidth_col2 = $table.($colNames[1]) | Measure-Object -Property { $_.ToString().Length } -Maximum | ForEach-Object Maximum
        # $width_rgb | Measure-Object -Property { $_.rgb.ToString().Length } -Maximum | ForEach-Object Maximum
        # $width_x11name = Measure-Object -Property { $_.X11ColorName.ToString().Length } -Maximum | ForEach-Object Maximum


        $table[0] | Join-String {
            @(
                # $_.RGB, $_.X11ColorName -join ':'
                # $_.rgb, $_.X11ColorName -join ':'
                'dsfs'
            ).PadLeft($width_x11name + 1)
            | New-Text -fg $_
        } -sep ' | ' -op '| ' -os ' | '
    }


    @(
        _randomRow_FormatStrPadLeft -count 3
        Hr
        0..3 | ForEach-Object {
            _randomRow_FormatStrPadLeft -count 3
        }
        Hr
        0..3 | ForEach-Object {
            _randomRow_StrPadLeft -count 5
        }
        Hr
        0..3 | ForEach-Object {
            _randomRow_SizedCols -count 5
        }

        h1 'auto sizes cols, but independantly'
        'auto sizes cols, but independantly'
        0..3 | ForEach-Object {
            # _randomRow_AutosizedCols -count 5
        }
        hr
        h1 'auto sizes cols, but whole table'
        'auto sizes cols, but whole table'
        0..3 | ForEach-Object {
            _randomTable_Autosized -count 5
        }


    ) | ForEach-Object ToString
}
