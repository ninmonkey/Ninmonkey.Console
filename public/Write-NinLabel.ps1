# New-Alias 'Label' -Value 'Write-NinLabel' -Description 'visual break using colors' -ErrorAction Ignore

function Write-NinLabel {
    [cmdletbinding(DefaultParameterSetName = 'TextFromPipe')]
    [Alias('Label')] #, 'Write-Label')]
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
        [Parameter(
            Mandatory, Position = 0, HelpMessage = 'Label or Heading')]
        [AllowEmptyString()]
        [string]$Label,

        [Parameter(
            ParameterSetName = 'TextFromPipe',
            Mandatory = $false, ValueFromPipeline,
            HelpMessage = 'text / content')]
        [Parameter(
            ParameterSetName = 'TextFromParam',
            Mandatory = $false, Position = 1,
            HelpMessage = 'Text is not required. defaults to no color.'
        )]
        [string[]]$Text,

        # todo: properties instead of needing % ProP to run
        # Property <Microsoft.PowerShell.Commands.PSPropertyExpression>

        [Parameter(
            HelpMessage = 'Seperator between Label and Text, default is ": "')]
        [string]$Separator = ': ',

        [Parameter(HelpMessage = 'Color as text/hex/rgb (Anything supported by "PoshCode.Pansies.RgbColor"')]
        [alias('Fg')]
        [PoshCode.Pansies.RgbColor]$ForegroundColor,

        [Parameter(HelpMessage = 'optional color for the rest of text')]
        [alias('Fg2')]
        [PoshCode.Pansies.RgbColor]$TextForegroundColor,

        [Parameter(HelpMessage = 'optional color for the rest of text')]
        [alias('Bg2')]
        [PoshCode.Pansies.RgbColor]$TextBackgroundColor,
        # todo: Default as null but use user preference default parameters

        [Parameter(
            HelpMessage = 'Color as text/hex/rgb (Anything supported by "PoshCode.Pansies.RgbColor"')]
        [alias('Bg')]
        [PoshCode.Pansies.RgbColor]$BackgroundColor,

        [Parameter(HelpMessage = 'number of blank lines before Label')]
        [Alias('Before')]
        [uint]$LinesBefore = 0,

        [Parameter(HelpMessage = 'number of blank lines after Label')]
        [Alias('After')]
        [uint]$LinesAfter = 0,

        [Parameter(HelpMessage = "Do not clear ANSI colors at the end")][switch]$LeaveColor

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

        if ($LinesBefore -gt 0) {
            '' * $LinesBefore
        }

        if ($Text) {
            $newTextSplat_Text['Object'] = $Text
            $StrText = New-Text @newTextSplat_Text
        }

        $FullString = $StrLabel, $Separator, $StrText | Join-String -Sep ''
        $FullString

        if ($LinesAfter -gt 0) {
            '' * $LinesAfter
        }

    }
    end {}

}
