#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Format-WrapJaykul'
    )
    $publicToExport.alias += @(

    )
}

function Format-WrapJaykul {

    <#
.SYNOPSIS
    Instead of columns, use alternating colors.
.DESCRIPTION
    source: https://gist.github.com/Jaykul/79b0f6f0ee44e06be56d2bd298ab084c
    # todo: update/extend
.example
    🐒> Get-Module
    | Format-wrapJaykul -RgbColor BrightRed, BrightGreen -padding 0
.example
    🐒> Import-module -PassThru -Name Pansies, ImportExcel, Pester
        | Format-WrapJaykul -RgbColor (Get-Gradient 'gray90' 'gray30' -Width 3) -Property {
        $_.Name, $_.Version -join ' ' }
.example
    🐒> Get-Content foo.txt
    | Format-wrapJaykul -RgbColor Cyan
.example
    🐒> Import-module -PassThru -Name Pansies, ImportExcel, Pester
        | Format-WrapJaykul -RgbColor 'red', 'blue', 'green' -Property {
            $_.Name, $_.Version -join ' ' }
.example
    # Calculated
    🐒> Gci
    | Format-WrapJaykul -RgbColor 'red', 'blue', 'green' -Property {
        $_.Name, $_.Length -join ' = ' }
.example
    🐒> Get-Service L*
    | Format-wrapJaykul -RgbColor 0x999999
.EXAMPLE
    🐒> gci
    | Format-WrapJaykul -RgbColor (Get-Gradient 'gray80' 'gray10' -Width 3)

    🐒> gci
    | Format-WrapJaykul -RgbColor (Get-Gradient 'gray80' 'gray10' -Width 3)







.ForwardHelpTargetName Microsoft.PowerShell.Utility\Format-Wide
.ForwardHelpCategory Cmdlet
#>

    [CmdletBinding(HelpUri = 'https://go.microsoft.com/fwlink/?LinkID=2096930')]
    param(
        [Parameter(Position = 0)]
        [System.Object]
        ${Property},

        [switch]
        ${AutoSize},

        [ValidateRange(0, 2147483647)]
        [int]
        ${Padding} = 1,

        [ValidateRange(1, 2147483647)]
        [int]
        ${Column},

        [System.Object]
        ${GroupBy},

        [string]
        ${View},

        [switch]
        ${ShowError},

        [switch]
        ${DisplayError},

        [switch]
        ${Force},

        [ValidateSet('CoreOnly', 'EnumOnly', 'Both')]
        [string]
        ${Expand},

        [Parameter(ValueFromPipeline = $true)]
        [psobject]
        ${InputObject},

        [Array]$RgbColor
    )

    begin {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer)) {
                $PSBoundParameters['OutBuffer'] = 1
            }

            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Format-Wide', [System.Management.Automation.CommandTypes]::Cmdlet)

            if ($RgbColor.Count -lt 1) {
                $RgbColor = @('', '')
            } else {
                $RgbColor = foreach ($C in @($RgbColor)) {
                    if ($C.Length -gt ($C -replace '\u001B.*?\p{L}').Length) {
                        $C
                    } elseif ($PSStyle.Foreground."$C") {
                        $PSStyle.Foreground."$C"
                    } else {
                        try {
                            $PSStyle.Foreground.FromRgb($C)
                        } catch {
                        ([PoshCode.Pansies.RgbColor]$C).ToVtEscapeSequence()
                        }
                    }
                }
                if ($RgbColor.Count -lt 2) {
                    $RgbColor += "$([char]27)[1;37m"
                }
            }

            $Wrap = $PSBoundParameters.Remove('RgbColor')
            $Wrap = $PSBoundParameters.Remove('Padding') -or $Wrap

            $scriptCmd = {
                & $wrappedCmd @PSBoundParameters | ForEach-Object { $c = 0 } {
                    $Item = $_
                    if (-not ($Item.PSTypeNames -match 'FormatEntryData')) {
                        Write-Host "$([char]27)[0m" -NoNewline
                        $Item
                    } elseif (!$Item.formatEntryInfo.formatPropertyField.propertyValue) {
                        $Item
                    } elseif ($Column -or $AutoSize -or !$Wrap) {
                        $Item.formatEntryInfo.formatPropertyField.propertyValue = "$($RgbColor[($c++) % $RgbColor.Count])$($Item.formatEntryInfo.formatPropertyField.propertyValue)"
                        $Item
                    } else {
                        Write-Host "$($RgbColor[($c++) % $RgbColor.Count])$($Item.formatEntryInfo.formatPropertyField.propertyValue)$(' ' * $Padding)" -NoNewline
                    }
                } { $PSStyle.Reset }
            }

            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process {
        try {
            $steppablePipeline.Process($(if ($_ -is [string]) {
                        [PSCustomObject]@{ String = $_ }
                    } else {
                        $_
                    }))
        } catch {
            throw
        }
    }

    end {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
}