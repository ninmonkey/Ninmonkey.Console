# New-Alias 'Label' -Value 'Write-NinLabel' -Description 'visual break using colors' -ErrorAction Ignore

function Write-ConsoleLabel {

    <#
    .synopsis
        visual break on output, similar to h1 with spacing and indentation removed.
    .description
        Command does not explicily write, so it can be piped to Write-Debug or write host

        future:
            - [ ] needs a pass over, this was written a long time ago, only for a profile
            - [ ] param -Property will auto-complete using 'psobject.properties'
                - [ ] even better, only if there's not already one, like 'enum'
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
        some examples in:
            'test\public\Write-ConsoleLabel.visual_tests.ps1'

        case1:
            Label 'Size:' $file -Prop Length
        param:
            -Label -Object -Prop

        case2:
            $File | Label 'Size:' -Prop Length
            # or
            $File | Label 'Size:' Length

            -Label -Prop
    #>
    [cmdletbinding(
        PositionalBinding = $false,
        DefaultParameterSetName = 'TextFromParam')]
    # DefaultParameterSetName = 'TextFromPipe')]
    [Alias('Label')] #, 'Write-NinLabel')] #, 'Write-Label')]
    param(
        # Label or Heading
        [Parameter(Mandatory, Position = 0)]
        [AllowEmptyString()] # simplifies users errors?
        [string]$Label,

        # Text / content
        [Alias('Text')]
        [Parameter(
            ParameterSetName = 'TextFromPipe',
            Mandatory = $false, ValueFromPipeline)]
        # Text is not required. defaults to no color.
        [Parameter(
            ParameterSetName = 'TextFromParam',
            Mandatory = $false, Position = 1)]
        # [string[]]$Text, # previously was
        # [object[]]$InputObject, # changed to to allow -Property Name
        [object]$InputObject, # changed to to allow -Property Name

        # Property to use, on a list of objects
        # future: calculated property that accepts scriptblocks
        # which set follows the same (offsets+1) pattern on param "-Text"
        # todo: properties instead of needing % Prop to run
        # Property <Microsoft.PowerShell.Commands.PSPropertyExpression>

        [Parameter(
            ParameterSetName = 'TextFromParam'
        )]
        # [Parameter(
        #     ParameterSetName = 'TextFromPipe',
        #     Position = 1
        # )]
        [string]$PropertyName,

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
        $strConst = @{
            Null = '[␀]' # U+2400 null symbol
        }
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
            # Object          = $Text # both are set later anyway
        }

        # how do I set
        $DebugPreference = 'SilentlyContinue'
        # $DebugPreference = $debug ?? 'SilentlyContinue'
        # note: explicitly formatted because Format-HashTable calls Label
        @{
            'ParameterSetName'  = $PSCmdlet.ParameterSetName
            'PSBoundParameters' = $PSBoundParameters
        } | Format-Table | Out-String | Write-Debug

        # $newTextSplat_Text | Format-Table | Out-String
        # | Write-Debug
    }
    Process {
        # write-error -ea Continue "rewrite: '$PSCommandPath'" # fix paramset when "label 'a' 'b'" fails

        # foreach ($Line in $Text) {
        $newTextSplat_Label['Object'] = $Label
        $newTextSplat_Label | Format-Table | Out-String | Write-Debug
        $StrLabel = New-Text @newTextSplat_Label

        return
        # if ($LinesBefore -gt 0) {
        #     '' * $LinesBefore
        # }

        Br -Count $LinesBefore


        # tofix: It's actually type object unless no property param
        if ($PropertyName) {
            # $newTextSplat_Text['Object'] = $Text.psobject.properties.$PropertyName
            $newTextSplat_Text['Object'] = $Text.$PropertyName
            if ($null -eq $Text.PropertyName) {
                # allow the user the option to continue with null value
                # future: test if property exist, then if null,
                #       then only error when propery name doesn't exist at all.
                Write-Error "Property '$PropertyName' is invalid or = $null"
                $newTextSplat_Text['Object'] = $strConst.Null
            }
        }
        else {
            $newTextSplat_Text['Object'] = $InputObject
        }

        #      = $Text
        #         $StrText = New-Text @newTextSplat_Text
        #     }
        #     else {

        #     }
        # }
        # $InputObject ??= $strConst.Null
        # if ($null -eq $newTextSplat_Text.Object) {
        if (
            [string]::IsNullOrWhiteSpace( $newTextSplat_Text.Object) ) {
            $StrText = New-Text @newTextSplat_Text
        }
        else {
            $StrText = ''
            Write-Error "-Object was $null"
        }
        $FullString = $StrLabel, $Separator, $StrText | Join-String -Sep ''
        $FullString
        Br -Count $LinesAfter

        # if ($LinesAfter -gt 0) {
        #     "`n" * $LinesAfter
        # }

    }
    end {
        # Write-Debug 'todo: rewrite to call Write-ConsoleText'
    }

}

# Write-Warning "Error: rewrite: '$PSCommandPath'" # fix paramset when "label 'a' 'b'" fails

@'
Label missing fail case:

    Label 'Final Query' $joinedQuery | Write-Information

'@
Write-Warning 'either: label or format-dict has a depth overflow'