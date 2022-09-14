
if ( $publicToExport ) {
    $publicToExport.function += @(
        'Get-SemanticColor'
    )
    $publicToExport.alias += @(
        'SemColor'
        'Sem->Color' # 'Get-SemanticColor'
    )
    # $publicToExport.variable += @(

    # )
}

function Get-SemanticColor {
    [Alias('SemColor', 'Sem->Color')]
    param( [string]$Name )


    $Colors = @{
        GroupA = @{
            # Reset        = "`e[0m"
            Reset        = $PSStyle.Reset
            # just use PSStyle
            # CtrlBlinkOff = "`e[25m"
            # CtrlBlink    = "`e[5m"
            # CtrlBoldOff = "`e[22m"
            # CtrlBold    = "`e[1m"

            FgGreen      = $PSStyle.Foreground.FromRgb('#80a36b')
            FgBoldGreen  = $PSStyle.Foreground.FromRgb('#8fc600') # neon
            # FgBlue   = $PSStyle.Foreground.FromRgb('#5a7a84')
            FgBlue       = $PSStyle.Foreground.FromRgb('#97dcff')
            FgWhite      = $PSStyle.Foreground.FromRgb('#dcdfe4')
            FgBlue2      = $PSStyle.Foreground.FromRgb('#699ab2')
            FgBoldBlue   = $PSStyle.Foreground.FromRgb('#3d7bd9')
            FgBoldOrange = $PSStyle.Foreground.FromRgb('#e69622')
            FgBoldYellow = $PSStyle.Foreground.FromRgb('#fbd600')
            FgGold       = $PSStyle.Foreground.FromRgb('#cca238')
            FgRed        = $PSStyle.Foreground.FromRgb('#e06c75')
            FgOrangeDim  = $PSStyle.Foreground.FromRgb('#c99076')
            FgPurple     = $PSStyle.Foreground.FromRgb('#b786c1')
            FgYellow     = $PSStyle.Foreground.FromRgb('#dbdc9e')
            FgGray       = $PSStyle.Foreground.FromRgb('#505867')

            FgDark15     = $PSStyle.Foreground.FromRgb('#282c34')
            BgDark15     = $PSStyle.Background.FromRgb('#282c34')
            # BgDark15   = $PSStyle.Background.FromRgb('#282c34')
            BgGray15     = "${bg:gray15}"
            BgGray30     = "${bg:gray30}"
            BgGray40     = "${bg:gray40}"
        }
    }
    $Mapping = switch ($ColorName) {
        { $_ -in 'GroupSegment' } { '#9933b9' } # severity 1
        # { $_ -in 'purpIsh' } { '#050586' } # severity 1
        { $_ -in 'ActualRequest' } { '#9933b9' } # severity 1
        { $_ -in 'Complete', 'CacheHit', 'green' } { '#96af84' } # severity 1
        { $_ -in 'FileIO' } { '#cffcff' } # severity 1
        { $_ -in @('Process', 'Processing') } { '#8fc0df' }
        { $_ -in 'bright', 'HttpRequest' } { '#c9e3e3' } # aka color0 | write-information
        { $_ -in 'tan' } { '#CB952D' } # severity 2
        { $_ -in 'yellow', 'warn' } { '#CB895D' } # severity 2
        { $_ -in 'red', 'bad', 'HttpError' } { '#d362a2' } # severity max
        { $_ -match 'gray\d+' } { $_ }
        default {
            # 'gray40'
            # [rgbcolor]$ColorName
            return
        }
    }

    return $Colors
}