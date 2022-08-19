if ( $publicToExport ) {
    $publicToExport.function += @(
        '__Jsonify_renderSampleProperties'
        '__newISet'
        '__Jsonify_queryPropertySets'
    )
    $publicToExport.alias += @(

    )
}




function __Jsonify_renderSampleProperties {
    <#
    .synopsis
        quick test to visualize from a dynamic list of properties - ie: Exploring for a new Jsonify Type
        .DESCRIPTION
            render as table and as a list
    #>
    param(
        # what to inspect
        [Parameter(Mandatory, Position = 0)]
        [object]$InputObject,

        # Names to inspect
        [Parameter(Mandatory, Position = 1)]
        [string[]]$PropertyName,

        # Names to inspect
        [ALias('First')]
        [Parameter(Mandatory, Position = 2)]
        [int]$LimitFirst = 3
    )

    $InputObject | Select-Object -First $LimitFirst
    | Select-Object -Property $PropertyName
    | Format-Table -AutoSize

    Hr

    $InputObject | Select-Object -First $LimitFirst
    | Select-Object -Property $PropertyName
    | Format-List
}

function __newISet {
    <#
            .synopsis
                sugar: new insensitive compared string set
         #>
    param(
        [Parameter()]
        [string[]]$InputText
    )
    $hset = [HashSet[string]]::new(
        $InputText,
        [System.StringComparer]::OrdinalIgnoreCase
    )
    return $hset
}




# # $all_propNames = (ps )[0].psobject.properties.name
# $p = $propNames = [ordered]@{
#     All = $t.psobject.properties.name
# }
# $hs = $hset = @{}
# $hset.All = _newISet $p.All

function __Jsonify_queryPropertySets {
    <#
    .synopsis
        quick test query type names based on conditions, to explore type name sets
    .DESCRIPTION

    #>
    param(
        # what to inspect
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject,

        [Parameter()]$Options = @{}

    )

    begin {

    }
    process {
        $meta = @{
            PSTypeName = '__jsonify.propertyName.Query'
        }
        $all_propNames = $InputObject.PSObject.Property.Name | Sort-Object -Unique

        $meta['Only_64bit'] = $all_propNames -match '64$'
        $meta['Only_Name'] = $all_propNames -match 'Name'
        $meta['Only_Type'] = $all_propNames -match 'Type'
        $meta['Only_Input'] = $all_propNames -match 'Input'
        $meta['Only_Output'] = $all_propNames -match 'Output'

        $meta['Only_TypeName'] = $all_propNames -match @(
            Join-Regex -LiteralText @(
                'Type', 'BaseType', 'Enum', 'Int', 'double', 'float', 'decimal',
                'string', 'List', 'hash', 'hashtable', 'collection'
            )
        )
        $meta['Only_Numeric'] = $all_propNames -match @(
            Join-Regex -LiteralText @(
                'Sum', 'total', 'count',
                'Size', 'total', 'max', 'min',
                'length', 'height', 'width'
            )
        )


        $meta['From_PSExtended'] = $InputObject.PSExtended.PSObject.Properties.Name | Sort-Object -Unique
        $meta['From_PSBase'] = $InputObject.PSBase.PSObject.Properties.Name | Sort-Object -Unique
        $meta['From_PSAdapted'] = $InputObject.PSAdapted.PSObject.Properties.Name | Sort-Object -Unique
        $meta['From_FindMember'] = $InputObject | ClassExplorer\Find-Member -MemberType Property
        $meta['From_FindMemberAndRelated'] = $InputObject
        | ClassExplorer\Find-Member -MemberType Property, NestedType, TypeInfo, Field

        $meta['From_GetMember'] = Write-Error 'left off here'
        $meta['From_GetMembeAndRelatedr'] = Write-Error 'left off here'

        $meta['Only_32Bit'] = $all_propNames | Where-Object { $all_propNames -contains "${_}64" }
        $meta['AllExcept_3264Bits'] = $all_propNames | Where-Object { $p.Only_64bit -notcontains $_ -and $p.Only_32Bit -notcontains $_ }

        return [pscustomobject]$Meta
    }
    end {
    }

}
