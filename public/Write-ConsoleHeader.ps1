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
        [ValidateNotNull()]
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

        # todo: Label-Rewrite: refactor, should be calling a shared, non-field function
        # for now fake it with empty
        $HeadingSplat = @{
            # Label           = $Name
            InputObject     = ''
            Separator       = ''
            Label           = $FinalName
            ForegroundColor = $ForegroundColor
            BackgroundColor = $BackgroundColor
            LinesBefore     = $LinesBefore
            LinesAfter      = $LinesAfter
        }

        Write-ConsoleLabel @HeadingSplat
    }
    end {}

}

Write-Warning 'Label-Rewrite: refactor, should be calling a shared, non-field function'
