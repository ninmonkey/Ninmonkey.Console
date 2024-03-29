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
    .EXAMPLE
        PS> gcm __func.*
        | select -exclude definition, scriptblock
        | iot2 -NotSkipMost -PassThru
        | Ft Name, Value, Reported, Type -AutoSize

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
        # [Parameter(Position = 0)]
        # [Alias('Layout')]
        # [ValidateSet(
        #     'Default', 'ByValue', 'ByRported'
        # )]
        # [string]$OutputFormat,

        [switch]$PassThru,
        [switch]$NotSkipMost

    )
    begin {
        # gcm __func.* | select -exclude definition, scriptblock | iot2 -NotSkipMost -PassThru
        # | Ft Name, Value, Reported, Type -AutoSize
        # gcm __func.* | select * | Format-Table -AutoSize 'Name', 'Reported', 'Value', 'Type'


    }
    process {
        $splat = @{}
        if ( $NotSkipMost ) { $splat.sm = $false } else { $splat.sm = $true }

        $query = $_ | Ninmonkey.Console\Inspect-ObjectProperty @splat
        | Sort-Object Name

        if ($PassTHru) { return $query }
        $query | Format-Table -AutoSize 'Name', 'Reported', 'Value', 'Type'

        # switch($OutputFormat) {
        #     'ByValue' {
        #         $query | Format-Table -AutoSize 'Name', 'Value', 'Reported', 'Type'
        #     }
        #     'ByReported' {
        #         $query | Format-Table -AutoSize 'Name', 'Reported', 'Value', 'Type'
        #     }
        #     default {
        #         $query | Format-Table -AutoSize 'Name', 'Reported', 'Value', 'Type'
        #     }
        # }
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
            ColumnNames = if ( $Columns ) { $columns } else { @('Name', 'Reported', 'Value', 'Type') }
        }
        if ($SortBy -isnot 'string') {
            throw 'ScriptBlock Implementation NYI, use string[s].'
        }
    }
    process {
        if ($Config.ColumnNames.count -eq 1 -and $Config.ColumnNames -match ',\s+') {
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
        quickly dump object property summaries
    .NOTES
        unstable, not ready for public consumption
        todo: make FormatData that sets max width on 'Value'
    .EXAMPLE
        $MyInvocation | io -SkipBlank | ? IsPrimitive -not  | ft
        $MyInvocation | io -SkipBlank -SkipPrimitive | ft
    .example

        gi . | io -SortBy <tab>

        # pressing tab to complete  -SortBy will cycle full templates. This

            gi . | io -SortBy <tab>

        # completes to this

            gi . | io -SortBy Type -SkipMost -SkipBlank -SkipPrimitive | ft Type, Name, Value -AutoSize
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
        [ArgumentCompletions(
            # experimenting with completing more than one command
            'Reported | Ft Reported, Name, Type, IsNull, Is*, Value -AutoSize',
            'Name | ft Type, Name, Value -AutoSize', # experimenting with completing more than one command
            'Type | ft Type, Name, Value -AutoSize',
            'Type -SkipMost -SkipBlank -SkipPrimitive | ft Type, Name, Value -AutoSize'   # experimenting with completing more than one command
        )]
        # [ValidateSet('Type', 'Value', 'Name', 'Length')]
        $SortBy = 'Type',

        # [switch]$SkipBasic, # Primitive,
        [Alias('sm')] # make skips also be a [string[]] list?
        [switch]$SkipMost, # Primitive,
        [switch]$SkipPrimitive, # Primitive,

        [switch]$SkipNull,

        # empty, null or whitespace
        [switch]$SkipBlank
        # s
    )
    begin {
        $IsBasicTypeNames_list = @('Int32', 'Int16', 'long', 'double', 'Byte', 'String')
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
        $validateSetValues = 'Type', 'Value', 'Name', 'Length', 'Reported', 'IsBlank', 'IsNull', 'IsEmptyStr'
        if ( $SortBy -notin $validateSetValues) {
            write-error 'invalid sortby type'
        }
        $summary = $InputObject.psobject.properties | ForEach-Object {
            $value_str = ($_)?.Value ?? ''

            $IsNull = $null -eq $value_str
            $IsBlank = [String]::IsNullOrWhiteSpace( $value_str )
            $IsEmptyStr = $_.Value -is 'string' -and $value_str -eq [String]::Empty
            $typeInfo = if ( -not $isNull) { ($_.Value)?.GetType() }

            <#
            was:
                $IsNull = $null -eq $_.Value
                $IsBlank = [String]::IsNullOrWhiteSpace( $_.Value )
                $IsEmptyStr = $_.Value -is 'string' -and $_.Value -eq [String]::Empty
                $typeInfo = if ( -not $isNull) { ($_.Value)?.GetType() }
            #>

            $isBasic = $false
            if ($typeInfo.Name -in $IsBasicTypeNames_list) {
                # to be extended
                $isBasic = $true
            }

            # $IsStrEmpty = $null -ne $_.Value -and $_.Value -is 'string' -and $_.Value.Length -eq 0 # overkill?
            # $_ | Format-List

            $reportedTypeName = $_.TypeNameOfValue -as 'type' | shortType
            $typeName = if ( -not $IsNull) {
               ($_)?.Value ?? '' | shortType
            }
            $HasSameTypes = $reportedTypeName -eq $typeName

            $meta = [ordered]@{
                PSTypeName = 'nin.SummarizedObject.Property'
                Reported   = $reportedTypeName
                Name       = $_.Name
                Type       = $typeName
                Value      = $_.Value
                ValueLength = ($_.Value)?.Length ?? "`u{2400}"
                IsBlank    = $IsBlank
                IsNull     = $isNull
                IsEmptyStr = $IsEmptyStr
                IsBasic    = $isBasicType
                TypeInfo   = $TypeInfo
                # IsEmptyList = $something -and $_.count -eq 0
            }

            if ($HasSameTypes) {
                $MergedTypes = $reportedTypeName   # $typeName
            }
            else {
                $MergedTypes = @(
                    "${fg:gray60}"
                    $reportedTypeName
                    # or newline, or both
                    # "`n"
                    ' 🠚 '
                    "${fg:gray90}"
                    if ($null -eq $_.Value) {
                        "`u{2400}"
                    }
                    else {
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



            # warning: May need to redo this logic, because of the interaction
            if ('Extra' -or $true) {
                $meta['IsPrimitive'] = $IsNull ? $false : ( ($_.Value)?.GetType().IsPrimitive ?? $false )
            }
            # write as new format data
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
