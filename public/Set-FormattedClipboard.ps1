function Set-FormattedClipboard {
    <#
    .synopsis
        exports object formatted as a table without truncated values
    .description

        useful if you ever want to save a Format-Table or Format-List to the clipboard

        This would fail:
            $object | Format-List | Set-Clipboard

        It's a macro for
            $object | Select-Object * | Format-List | Out-String -Width 999 | Set-Clipboard
    .notes
        todo:

        - [ ] Set-ClipBoard -Append ?
        - [ ] auto detect whether passed object is of format type
            - removing -Mode 'None'
            - ex: 'Microsoft.PowerShell.Commands.Internal.Format.FormatEndData'


    #>
    param(
        # Input object
        [Parameter(Mandatory, Position = 0)]
        $InputObject,

        # Which type of formatting to use? Format-Table, Format-List. Use none if already formatted.
        [Parameter(Position = 1)]
        [ValidateSet('Table', 'List', 'None')]
        [String]$FormatMode = 'Table',

        # -Width for Out-String
        [Parameter(Position = 2)]
        [int]$Width,

        # temporarily overrides '$FormatEnumerationLimit'
        [Parameter()]
        [int]$EnumerationLimit
    )

    begin {
        $splat_FormatTable = @{
            # 'AutoSize' = ...
            # 'DisplayError' = ...
            # 'Expand' = ...
            # 'Force' = ...
            # 'GroupBy' = ...
            # 'HideTableHeaders' = ...
            # 'InputObject' = ...
            # 'Property' = ...
            # 'RepeatHeader' = ...
            # 'ShowError' = ...
            # 'View' = ...
            # 'Wrap' = ...
        }
        $splat_FormatList = @{
            # DisplayError
            # Expand
            # Force
            # GroupBy
            # InputObject
            # Property
            # ShowError
            # View
        }
        $splat_OutString = @{
            Width = ($null -eq $Width) ? 9999 : $Width
        }
        $splat_SelectObject = @{
            Property = '*'
        }
    }

    process {
        $PrevEnumLimit = $FormatEnumerationLimit
        if (! ($null -eq $EnumerationLimit)) {
            $FormatEnumerationLimit = $EnumerationLimit
        }

        switch ($FormatMode) {
            'List' {
                $InputObject | Select-Object @splat_Select
                | Format-List @splat_FormatList | Out-String @splat_OutString | Set-Clipboard

                break
            }
            'Table' {
                $InputObject | Select-Object @splat_Select
                | Format-Table | Out-String  @splat_OutString | Set-Clipboard

                break
            }
            'None' {
                $InputObject | Out-String @splat_OutString | Set-Clipboard
                break
            }
            default {
                throw "NYI: FormatMode: $FormatMode"
            }
        }
        $InputObject | Select-Object @splat_Select
        $object

        $EnumerationLimit = $PrevEnumLimit

    }

}
