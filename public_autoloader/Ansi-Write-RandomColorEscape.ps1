#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        '_randColorEscape'
    )
    $publicToExport.alias += @(

    )
}


function _randColorEscape {
    # return either color or rendered escape
    [outputType(
        'PoshCode.Pansies.RgbColor',
        'system.string'
    )]
    param(
        # render includes rand FG
        [Alias('Fg')]
        [switch]$Foreground,

        # render includes rand BG
        [Alias('Bg')]
        [switch]$Background,

        # returns meta
        [switch]$PassTru
    )

    $cfg = 0..255 | Get-Random -Count 3
    $cbg = 0..255 | Get-Random -Count 3

    $pansies = [rgbcolor]::FromRgb($cfg[0], $cfg[1], $cfg[2])
    $render_fg = $PSStyle.Foreground.FromRgb( $cfg[0], $cfg[1], $Cfg[2])
    $render_bg = $PSStyle.Background.FromRgb( $cbg[0], $cbg[1], $Cbg[2])
    if (! $Foreground ) {
        $render_fg = ''
    }
    if (! $Background) {
        $render_bg = ''
    }

    $render_all = $render_fg + $render_bg

    $meta = @{
        RandColors = $c
        RgbColor   = $pansies
        FgColor    = $render_fg
        BgColor    = $render_bg
        AllColor   = $render_all
        # FgColor    = $Foreground ? $render_fg : ''
        # BgColor    = $Background ? $render_bg : ''
    }
    if ($PassTru) {
        return [pscustomobject]$meta
    }
    return $render_all
}

