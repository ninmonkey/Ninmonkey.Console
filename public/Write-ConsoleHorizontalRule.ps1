function Write-ConsoleHorizontalRule {
    <#
    .SYNOPSIS
        adds a visual break / horizontal line to the console
    .Example
        "line1"; hr; "line2"

    .Example
        "line1"; hr -ExtraLines 3;  "line2"

    #>
    [alias('Hr')]
    [cmdletbinding(PositionalBinding = $false
        #,  DefaultParameterSetName = 'NoPipelineInput'
    )]
    param(
        # Number of lines to pad
        [Parameter(Position = 0)]
        [int]$ExtraLines = 0,


        # 'Color as text/hex/rgb (Anything supported by "PoshCode.Pansies.RgbColor"'
        [Parameter()]
        [alias('Fg')]
        [PoshCode.Pansies.RgbColor]$ForegroundColor = 'gray60'

        # # disable color
        # [Parameter()][switch]$NoColor,
        # # number of blank lines before Label
        # [Parameter()]
        # [Alias('Before')]
        # [uint]$LinesBefore = 0,

        # # Number of blank lines after Label
        # [Parameter()]
        # [Alias('After')]
        # [uint]$LinesAfter = 0,
    )
    # $suffix = $prefix = "`n" * $ExtraLines
    begin {}
    process {
        $w = $host.ui.RawUI.WindowSize.Width
        $chars = '-' * $w -join ''
        $padding = "`n" * $ExtraLines

        $output = @(
            $padding, $chars, $padding
        ) -join ''

        if ($NoColor) {
            $output
        }
        else {
            New-Text $output -fg $ForegroundColor
            | ForEach-Object ToString # Do I want to force string here?
        }
    }
    end {}
}


# & {
#     $w = $host.ui.RawUI.WindowSize.Width
#     $chars = '-' * $w -join ''
#     if ($ExtraLines -gt 0) {
#         @("`n" * $ExtraLines), $chars, ("`n" * $ExtraLines) -join ''
#     }
#     else {
#         $chars
#     }
# } | New-Text -fg 'gray50' | ForEach-Object tostring

# New-Alias 'Label' -Value 'Write-NinLabel' -Description 'visual break using colors' -ErrorAction Ignore

function Write-ConsoleHeader {
    [cmdletbinding(DefaultParameterSetName = 'TextFromPipe')]
    [Alias('H1')]
    <#
    .synopsis
        visual break on output, similar to <h1> or markdown headers
    .description
        Command does not explicily write, so it can be piped to Write-Debug or write host
    .example

    .example
    .notes
        some examples at 'test\public\Write-ConsoleLabel.visual_tests.ps1'

    #>
    param(
        # Header text
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$Name,

        # 'Color as text/hex/rgb (Anything supported by "PoshCode.Pansies.RgbColor"'
        [Parameter()]
        [alias('Fg')]
        [PoshCode.Pansies.RgbColor]$ForegroundColor = '#EBCB8B',
        #'Orange',

        # 'Color as text/hex/rgb (Anything supported by "PoshCode.Pansies.RgbColor"'
        [Parameter()]
        [alias('Bg')]
        [PoshCode.Pansies.RgbColor]$BackgroundColor,

        # number of blank lines before Label
        [Parameter()]
        [Alias('Before')]
        [uint]$LinesBefore = 1,

        # number of blank lines after Label
        [Parameter()]
        [Alias('After')]
        [uint]$LinesAfter = 1, #0,

        # how deep, h1 to h6
        [Parameter()]
        [uint]$Depth = 1,

        # No padding
        [Parameter()][switch]$NoPadding

    )

    begin {
        $Template = @{
            PaddingString = '#'
        }
    }
    Process {
        # use h1..h6, else ignore?
        $PaddingPrefix = ( '#' * $Depth ) -join ''
        $FinalName = if ($Depth -gt 0 -and ! $NoPadding) {
            #was:  -and -le 6) {
            "$PaddingPrefix $Name"
        }
        else {
            $Name
        }

        $HeadingSplat = @{
            # Label           = $Name
            Label           = $FinalName
            Separator       = ''
            Text            = ''
            ForegroundColor = $ForegroundColor
            BackgroundColor = $BackgroundColor
            LinesBefore     = $LinesBefore
            LinesAfter      = $LinesAfter
        }

        Label @HeadingSplat
    }
    end {}

}
