
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
    <#
    .SYNOPSIS
        IIRC the idea was perhaps two styles: [1] one is a theme like GroupA ie:console16color, or, [2] a mapping of single names to a single color
    .EXAMPLE
        Get-SemanticColor 'FileIO'
            '#cffcff'
    #>

    [Alias('SemColor', 'Sem->Color')]
    [OutputType(
        'System.String'
    )]
    param(
        # future will autocomplete valid values, or at least suggests keys
        [ArgumentCompletions(
            'Color1',
            'FileIO', 'Bright',
            'Complete', 'Tan', 'Yellow', 'Red',
            'Gray80', 'Gray75', 'Gray60', 'Gray50',

            'FgBlue',
                'FgBlue2', 'FgBlue3',
                'FgBoldBlue',

            'Gray40', 'Gray15', 'Gray30', 'Gray15',
            'Gray100', 'Gray0',

                    'BgDark15',
                    'BgGray15',
                    'BgGray30',
                    'BgGray40',
                    'FgBlue',
                    'FgBlue2',
                    'FgBoldBlue',
                    'FgBoldGreen',
                    'FgBoldOrange',
                    'FgBoldYellow',
                    'FgDark15',
                    'FgGold',
                    'FgGray',
                    'FgGreen',
                    'FgOrangeDim',
                    'FgPurple',
                    'FgRed',
                    'FgWhite',
                    'FgYellow',

                'GroupSegment',
                'ActualRequest',
                'Complete',
                'CacheHit',
                'green',
                'FileIO',
                'Process',
                'Processing',
                'bright',
                'HttpRequest',
                'tan',
                'warn',
                'bad',
                'HttpError'
        )]
        [Alias('Name', 'SemName')]
        [Parameter(position = 0)]
        [string]$ColorName
    )


    write-verbose 'unfinished. should return structred types, then they can render to screen (safely) as a format, else escapes when coercing to a string'


    $Colors = @{
        GroupA = [pscustomobject]@{
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
        { $_ -in 'purpIsh' } { '#050586' ; break; } # severity 1
        { $_ -in 'GroupSegment' } { '#9933b9' ; break; } # severity 1
        { $_ -in 'ActualRequest' } { '#9933b9' ; break; } # severity 1
        { $_ -in 'Complete', 'CacheHit', 'green' } { '#96af84' ; break; } # severity 1
        { $_ -in 'FileIO' } { '#cffcff' ; break; } # severity 1
        { $_ -in @('Process', 'Processing') } { '#8fc0df' }
        { $_ -in 'bright', 'HttpRequest' } { '#c9e3e3' ; break; } # aka color0 | write-information
        { $_ -in 'tan' } { '#CB952D' ; break; } # severity 2
        { $_ -in 'yellow', 'warn' } { '#CB895D' ; break; } # severity 2
        { $_ -in 'red', 'bad', 'HttpError' } { '#d362a2' ; break; } # severity max
        { $_ -match 'gray\d+' } { $_ ; break;}
        default {
            @(
                "unknown color: $ColorName , try 'Group1'"
                $Colors.GroupA.PSObject.Properties.Name
                    | Join-String -sep ' ' -op 'which contains: '
            ) | Join-String | write-debug

            # new default logic, break and attempt fallbacks, below
        }
    }
    if($Mapping) {
        "SemColor::Mapping $ColorName == $($Mapping | fcc)" | Write-debug
        return $Mapping
    }

    if($ColorName -in @($Colors.GroupA.PSObject.Properties.Name)) {
        "SemColor::Group1.$ColorName" | Write-debug
        return $Colors.Group1.$ColorName
    }

    write-debug 'No basic mapping, falling back to Group = "Group1"'
    return $Colors.Group1
}