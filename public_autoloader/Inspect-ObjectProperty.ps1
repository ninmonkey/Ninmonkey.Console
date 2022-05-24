#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Inspect-ObjectProperty'
    )
    $publicToExport.alias += @(
        # 'Inspect-ObjectProperty'

    )
}
# new

# Import-Module ClassExplorer
# Import-Module ninmonkey.console -Force

function InspectObject {
    [Alias('getProps')]
    param(
        # Any object
        [ValidateNotNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        # [switch]$SkipBasic, # Primitive,

        [switch]$SkipNull,

        # empty, null or whitespace
        [switch]$SkipBlank,

        [ValidateSet('Default', 'Length', 'Type', 'Value', 'Name')]
        $SortBy = 'Default'

        # s
    )
    begin {
        $Str = @{
            'NullSymbol' = "<`u{2400}>"
            'TrueNull'   = '<Null>'
            'Blank'      = '<Blank>'
            'Reset'      = $PSStyle.Reset
            'FgDim'      = $PSStyle.Foreground.FromRgb('#777777')
        }
    }
    process {
        $summary = $InputObject.psobject.properties | ForEach-Object {
            $IsNull = $null -eq $_.Value
            $IsBlank = [String]::IsNullOrWhiteSpace( $_.Value )
            $IsEmptyStr = $_.Value -is 'string' -and $_.Value -eq [String]::Empty
            # $IsStrEmpty = $null -ne $_.Value -and $_.Value -is 'string' -and $_.Value.Length -eq 0 # overkill?
            # $_ | Format-List

            $meta = @{
                PSTypeName = 'nin.SummarizedObject.Property'
                Reported   = $_.TypeNameOfValue -as 'type' | shortType # Format-ShortSciTypeName
                Type       = if (! $IsNull) {
                    $_.Value | shortType
                }
                Name       = $_.Name
                Value      = $_.Value
                IsBlank    = $IsBlank
                IsNull     = $isNull
                IsEmptyStr = $IsEmptyStr
                # IsEmptyList = $something -and $_.count -eq 0
            }
            if ('Extra' -or $true) {
                $meta['IsPrimitive'] = $IsNull ? $false : ( $_.Value.GetType().IsPrimitive ?? $false )
            }
            if ($True -and 'move to custom formatdata') {
                if ($IsBlank) {
                    # move to formatter
                    $meta['Value'] = @(

                        $Str.FgDim
                        $Str.Blank
                        $PSStyle.Reset
                    ) -join ''
                }
                if ($IsNull) {
                    # move to formatter
                    $meta['Value'] = @(
                        $Str.FgDim
                        $Str.NullSymbol
                        $PSStyle.Reset
                    ) -join ''
                }
            }
            return [pscustomobject]$meta
        }
        # exfiltrate filtering logic ?
        $filtered = $summary | Where-Object {
            if ($SkipNull -and $_.IsNull) {
                return $false
            }
            if ($SkipBlank -and $_.IsBlank) {
                return $false
            }
            return $true

        }
        $ordered = $filtered | ForEach-Object {
            $_
        }
        $ordered | Sort-Object
    }
}

# if ($false) {

#     $summary = (Get-Item .) | InspectObject

#     H1 'all table'
#     $summary | Format-Table -auto

#     H1 'short list'
#     $summary | s -first 2 | Format-List
#     #| Format-Table -AutoSize

#     H1 'show null render'
#     $summary | Where-Object { $_.Name -match 'target' }

# }
