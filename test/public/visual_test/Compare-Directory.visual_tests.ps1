Import-Module Ninmonkey.Console -Force

$diffDirSplat = @{
    Path1             = 'C:\Users\cppmo_000\Documents\2020\python\proto\discord_bots\webhook_2021'
    Path2             = 'C:\Users\cppmo_000\Documents\2021\Python\My_Github\DiscordAlert.py'
    # FormatMode        = 'Raw', 'All'
    InformationAction = 'Continue'
}

DiffDir @diffDirSplat
#-FormatMode 'All', 'Diff'
h1 'test3' -bg 'magenta' -before 4 -after 4
$res = Compare-Directory @diffDirSplat -FormatMode 'all' -informationaction continue
hr 2; $res

hr 20

if ($true) {
    # nicer 'diff' output ?
    $useRelative = $true
    $path1 = 'C:\Users\cppmo_000\Documents\2020\python\proto\discord_bots\webhook_2021' | Get-Item -ea stop
    $path2 = 'C:\Users\cppmo_000\Documents\2021\Python\My_Github\DiscordAlert.py' | Get-Item -ea stop
    $out = Invoke-NativeCommand 'diff' @('-q', $path1, $path2)

    h1 'raw original output'
    $out

    if ($useRelative) {
        $Label1 = $path1 | Split-Path -Leaf | New-Text -fg 'green'
        $Label2 = $path2 | Split-Path -Leaf | New-Text -fg 'blue'
        $out = $out -replace [regex]::Escape($path1), $Label1
        $out = $out -replace [regex]::Escape($path2), $Label2
    }

    h1 'with -UseRelative'
    $out

    h1 'filter: "only in"'
    $out | rg 'only in'
    h1 'filter: "differ"'
    $out | rg 'differ'

}
