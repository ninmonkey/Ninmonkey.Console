# New-Alias 'Label' -Value 'Write-NinLabel' -Description 'visual break using colors' -ErrorAction Ignore

function Write-ConsoleText {
    [cmdletbinding(DefaultParameterSetName = 'TextFromPipe')]
    # Pansi lib uses alias 'text', maybe cText or color
    [Alias('Write-Text', 'Write-Color')] # mabye: Write-Text ?
    # [Alias('Text', 'Write-Color')] # maybe: Write-Text ?
    <#
    .synopsis
        Return a colorized string
    .description
        Base function used by other commands like Write-ConsoleHeader, Write-ConsoleLabel

        - Unlike [PoshCode.Pansies.Text], this returns a regular [String] immediately
        - Unlike [Write-ConsoleLabel], it does not default to key-value pair
        - Unlike [Write-ConsoleHeader], it does not default to adding padding or any newline
    .example
    .notes
    #>
    param(
        # Header text
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$Name,

        # 'Color as text/hex/rgb (Anything supported by "PoshCode.Pansies.RgbColor"'
        [Parameter()]
        [alias('Fg')]
        [PoshCode.Pansies.RgbColor]$ForegroundColor = 'Orange',

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
        [uint]$LinesAfter = 0,

        # how deep, h1 to h6
        [Parameter()]
        [uint]$Depth = 1,

        # No padding
        [Parameter()][switch]$NoPadding

    )

    begin {
        # $Template = @{
        #     PaddingString = '#'
        # }
        throw "$PSScriptRoot : WIP"
    }
    Process {
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
