# New-Alias 'Label' -Value 'Write-NinLabel' -Description 'visual break using colors' -ErrorAction Ignore

function Write-ConsoleLabel {
    [cmdletbinding(DefaultParameterSetName = 'TextFromPipe')]
    [Alias('Label')] #, 'Write-NinLabel')] #, 'Write-Label')]
    <#
    .synopsis
        visual break on output, similar to h1 with spacing and indentation removed.
    .description
        Command does not explicily write, so it can be piped to Write-Debug or write host
    .example
        PS> Label 'started' 'processname'
    .example
        # compare resetting/clearing color

        1, 2 | Label 'num' -LeaveColor -fg 'orange' | Join-String -Sep ' --  '
        1, 2 | Label 'num' -fg 'orange' | Join-String -Sep ' --  '

    .example
        ls env: | foreach-object {
            Label -Label ($_.Key + ': ') -Text $_.Value
        }
        # output env vars with colord names
    .notes
        some examples at 'test\public\Write-ConsoleLabel.visual_tests.ps1'
    #>
    param(
        # Label or Heading
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()]
        [string]$Label,

        # Text / content
        [Parameter(ParameterSetName = 'TextFromPipe', Mandatory = $false, ValueFromPipeline)]
        # Text is not required. defaults to no color.
        [Parameter(ParameterSetName = 'TextFromParam', Mandatory = $false, Position = 1)]
        [string[]]$Text,

        # todo: properties instead of needing % ProP to run
        # Property <Microsoft.PowerShell.Commands.PSPropertyExpression>

        # Seperator between Label and Text, default is ": "
        [Parameter()]
        [string]$Separator = ': ',

        # Color as text/hex/rgb (Anything supported by "PoshCode.Pansies.RgbColor"
        [Parameter()]
        [Alias('Fg')]
        [PoshCode.Pansies.RgbColor]$ForegroundColor,

        # optional color for the rest of text
        [Parameter()]
        [Alias('Fg2')]
        [PoshCode.Pansies.RgbColor]$TextForegroundColor,

        # optional color for the rest of text
        # todo: Default as null but use user preference default parameters
        [Parameter()]
        [Alias('Bg2')]
        [PoshCode.Pansies.RgbColor]$TextBackgroundColor,

        # Color as text/hex/rgb (Anything supported by "PoshCode.Pansies.RgbColor"
        [Parameter()]
        [Alias('Bg')]
        [PoshCode.Pansies.RgbColor]$BackgroundColor,

        # number of blank lines before Label
        [Parameter()]
        [Alias('Before')]
        [uint]$LinesBefore = 0,

        # Number of blank lines after Label
        [Parameter()]
        [Alias('After')]
        [uint]$LinesAfter = 0,

        # Do not clear ANSI colors at the end
        [Parameter()][switch]$LeaveColor

    )

    begin {
        $newTextSplat_Label = @{
            ForegroundColor = $ForegroundColor ?? 'green'
            BackgroundColor = $BackgroundColor
            # Separator = 'x'
            LeaveColor      = $LeaveColor
            IgnoreEntities  = $true
            Object          = $Label # both are set later anyway
        }
        $newTextSplat_Text = @{
            ForegroundColor = $TextForegroundColor
            BackgroundColor = $TextBackgroundColor
            # Separator = 'x'
            LeaveColor      = $LeaveColor
            IgnoreEntities  = $true
            Object          = $Text # both are set later anyway
        }

        @{
            'ParameterSetName'  = $PSCmdlet.ParameterSetName
            'PSBoundParameters' = $PSBoundParameters
        } | Format-Table |  Out-String | Write-Debug

        # $newTextSplat_Text | Format-Table | Out-String
        # | Write-Debug
    }
    Process {
        # foreach ($Line in $Text) {
        $newTextSplat_Label['Object'] = $Label
        $newTextSplat_Label | Format-Table | Out-String | Write-Debug
        $StrLabel = New-Text @newTextSplat_Label

        # if ($LinesBefore -gt 0) {
        #     '' * $LinesBefore
        # }

        Br -Count $LinesBefore

        if ($Text) {
            $newTextSplat_Text['Object'] = $Text
            $StrText = New-Text @newTextSplat_Text
        }

        $FullString = $StrLabel, $Separator, $StrText | Join-String -Sep ''
        $FullString
        Br -Count $LinesAfter

        # if ($LinesAfter -gt 0) {
        #     "`n" * $LinesAfter
        # }

    }
    end {
        Write-Debug 'rewrite to call Write-ConsoleColor'
    }

}
