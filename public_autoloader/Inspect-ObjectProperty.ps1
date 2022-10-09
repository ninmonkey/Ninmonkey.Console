#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Inspect-ObjectProperty'
        'iot', 'iot2'
    )
    $publicToExport.alias += @(
        'InspectObject'  # 'Inspect-ObjectProperty'
        # 'getProps'  # 'Inspect-ObjectProperty'
        'Inspect->ObjectProp'  # 'Inspect-ObjectProperty'

    )
}
# new

# Import-Module ClassExplorer
# Import-Module ninmonkey.console -Force

function iot {
    <#
    .SYNOPSIS
        sugar with best defaults for Inspect-ObjectProperty

        I *want* Value as first column, just truncated for width
        Using ShortStr inside a formatter
    .LINK
        Ninmonkey.Console\Inspect-ObjectProperty
    #>
    param(
        [switch]$ViewB
    )
    $PropList = 'Reported', 'Type', 'Name', 'Value'
    $PropListB = 'Type', 'Name', 'Reported', 'Value'
    $inspectObjectPropertySplat = @{
        # SkipBlank = $true
        # SkipMost = $true
        # SkipNull = $true
        # SkipPrimitive = $true
        # SortBy = 'Value'
    }

    $formatTableSplat = @{
        AutoSize = $true
        Property = $PropList
    }
    if ($ViewB) {
        $formatTableSplat.Property = $PropListB
    }

    $Input
    | Ninmonkey.Console\Inspect-ObjectProperty @inspectObjectPropertySplat
    | Format-Table @formatTableSplat
}
function iot2 {
    <#
    .SYNOPSIS
        sugar with best defaults for Inspect-ObjectProperty
    .NOTES
        todo:
            refactor into TypeData and FormatData, with optional views
    .link
        Ninmonkey.Console\Inspect-ObjectProperty
    #>
    # [OutputType('[PSCustomObject[]]', 'String')]
    # [CmdletBinding()]
    param(
        # which columns to use?
        # [ArgumentCompletions(
        #     'Name, Reported, Value, Type',
        #     'Name, Reported, Type, Value'
        # )]
        # [string[]]$ColumnName,
        # [object]$SortBy = 'Name',
        [switch]$PassThru,
        [switch]$NotSkipMost
    )
    begin {

    }
    process {
        $splat = @{}
        if( $NotSkipMost ) { $splat.sm = $false } else { $splat.sm = $true }

        $query = $_ | Ninmonkey.Console\Inspect-ObjectProperty @splat
        | Sort Name

        if($PassTHru) { return $query }

        $query | Format-Table -AutoSize 'Name', 'Reported', 'Value', 'Type'
    }
    end {}

}


function iot.dev2 {
    <#
    .SYNOPSIS
        sugar with best defaults for Inspect-ObjectProperty
    .NOTES
        todo:
            refactor into TypeData and FormatData, with optional views
    .link
        Ninmonkey.Console\Inspect-ObjectProperty
    #>
    param(
        # which columns to use?
        [ArgumentCompletions(
            'Name, Reported, Value, Type',
            'Name, Reported, Type, Value'
        )]
        [string[]]$ColumnName,
        [object]$SortBy = 'Name',
        [switch]$NotSkipMost
    )
    begin {
        [hashtable]$Config = Join-Hashtable -OtherHash $Options -BaseHash @{
            ColumnNames = if( $Columns ) { $columns } else { @('Name', 'Reported', 'Value', 'Type') }
        }
        if($SortBy -isnot 'string') {
            throw "ScriptBlock Implementation NYI, use string[s]."
        }
    }
    process {
        if($Config.ColumnNames.count -eq 1 -and $Config.ColumnNames -match ',\s+') {
            $Config.ColumnNames = [string[]]@($Config.ColumnNames -split ',\s+')
        }
        # gi . | iot | ft
        # gi . | iot -ViewB | ft
        # gi . | io -SortBy Type | ft -AutoSize Name, Reported, Value, is* # alternate
        $_
        | Ninmonkey.Console\Inspect-ObjectProperty -sm:( -not $NotSkipMost )
        | Format-Table -AutoSize $Config.ColumnNames
    }
    end {}

}


function Inspect-ObjectProperty {
    <#
    .SYNOPSIS
        quick obj property summarizes
    .NOTES
        todo: make FormatData that sets max width on 'Value'
    .EXAMPLE
        $MyInvocation | io -SkipBlank | ? IsPrimitive -not  | ft
        $MyInvocation | io -SkipBlank -SkipPrimitive | ft
    #>
    [Alias(
        'InspectObject',
        # 'getProps',
        'Inspect->ObjectProp'
    )]
    param(
        # Any object
        # [ValidateNotNull()]
        [AllowNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        # [switch]$SkipBasic, # Primitive,
        [Alias('sm')]
        [switch]$SkipMost, # Primitive,
        [switch]$SkipPrimitive, # Primitive,

        [switch]$SkipNull,

        # empty, null or whitespace
        [switch]$SkipBlank,

        [ValidateSet('Type', 'Value', 'Name', 'Length')]
        $SortBy = 'Type'

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
        if ($SkipMost) {
            $SkipPrimitive = $True
            $SkipNull = $true
            $SkipBlank = $true
        }
    }
    process {
        if ($Null -eq $InputObject) {
            return
        }
        $summary = $InputObject.psobject.properties | ForEach-Object {
            $IsNull = $null -eq $_.Value
            $IsBlank = [String]::IsNullOrWhiteSpace( $_.Value )
            $IsEmptyStr = $_.Value -is 'string' -and $_.Value -eq [String]::Empty
            # $IsStrEmpty = $null -ne $_.Value -and $_.Value -is 'string' -and $_.Value.Length -eq 0 # overkill?
            # $_ | Format-List

            $reportedTypeName = $_.TypeNameOfValue -as 'type' | shortType
            $typeName = if (! $IsNull) {
                $_.Value | shortType
            }
            $HasSameTypes = $reportedTypeName -eq $typeName

            $meta = @{
                PSTypeName = 'nin.SummarizedObject.Property'
                Reported   = $reportedTypeName
                Type       = $typeName
                Name       = $_.Name
                Value      = $_.Value
                IsBlank    = $IsBlank
                IsNull     = $isNull
                IsEmptyStr = $IsEmptyStr
                # IsEmptyList = $something -and $_.count -eq 0
            }

            if ($HasSameTypes) {
                $MergedTypes = $reportedTypeName   # $typeName
            } else {
                $MergedTypes = @(
                    "${fg:gray60}"
                    $reportedTypeName
                    # or newline, or both
                    # "`n"
                    ' 🠚 '
                    "${fg:gray90}"
                    if ($null -eq $_.Value) {
                        "`u{2400}"
                    } else {
                        $typeName
                    }
                ) -join ''
            }

            # $ReportedType = if
            $meta += @{
                #
                # temp hack ; shouldn't be a property, should be class field properties or formatData
                HasSameTypeNames  = $HasSameTypes
                ReportedType      = $ReportedType
                MergedTypes       = $MergedTypes

                ShortMergedTypes  = $ReportedType -split '' # add newlines instead of only truncating
                | Select-Object -First 40 | Join-String -sep ''

                ShortReportedType = $ReportedType -split ''
                | Select-Object -First 40 | Join-String -sep ''

                ShortValue        = ($_.Value)?.ToString() -split ''
                | Select-Object -First 40 | Join-String -sep ''

                ShortType         = $meta['Type'] -split ''
                | Select-Object -First 40 | Join-String -sep ''


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
            if ($SkipPrimitive -and $_.IsPrimitive) {
                return $false
            }
            return $true

        }
        $ordered = $filtered | ForEach-Object {
            $_
        }
        $ordered | Sort-Object -Property $SortBy
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
