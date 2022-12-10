using namespace system.collections.generic

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Get-PropertyEnumerator'
        'Get-BaseTypeInfo'
        'iprop.basic'
    )
    $publicToExport.alias += @(
        'iter->Prop' # 'Get-PropertyEnumerator'

        # 'Get-TypeOf'  # 'ZD-Get-BaseTypeInfo'
    )
}


function iprop.basic {
    <#
        .synopsis
            sugar to iterate over properties
        .example
            gi . |  iprop | ft Name, TypeNameOfValue, Value
        .example
            gi . | iprop
            | sort TypeNameOfValue, Name
            | ft -AutoSize Name, Value -GroupBy TypeNameOfValue
        .example
             get-date | iprop | ? TypeNameOfValue -notmatch 'string|int' |Ft
        #>

    process {
        $_.PSObject.Properties | Sort-Object Name
    }
}

function Get-BaseTypeInfo {
    <#
    .synopsis
        Basic type info
    .example
        PS> gi . | ZD-Get-BasicTypeInfo

    #>
    [Alias('Get-TypeOf')]
    [cmdletbinding()]
    param(
        # What to enumerate
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        [list[object]]$items = [list[object]]::new()
    }
    process {
        $items.AddRange( $InputObject )
    }
    end {
        $uniqueItem = $items | Get-Unique -OnType
        $uniqueItem | ForEach-Object {
            $Cur = $_
            $tinfo = @{
                PSTypeName    = 'zeroDependency.TypeInfo'
                Object        = $cur
                Name          = $cur.GetType().Name
                FullName      = $cur.GetType().FullName
                'PSTypes'     = $cur.PSTypeNames
                'PSTypes_Csv' = $cur.PSTypeNames | Join-String -sep ' ' { '[{0}]' -f $_ }
            }
            return [pscustomobject]$tinfo

        }
        # return $items.psobject.properties
    }
}
function Get-PropertyEnumerator {
    <#
    .synopsis
        iterate/enumerate an object's properties  [zero dependency]
    .example
        PS> gi . | IterProp
    .example
        PS> (get-date) | iterProp | Ft -AutoSize MemberType, Name, Value, TypeNameOfValue


        MemberType Name                            Value TypeNameOfValue IsInstance IsSettable IsGettable
        ---------- ----                            ----- --------------- ---------- ---------- ----------
        Property Capacity                            4 System.Int32          True       True       True
        Property Count                               1 System.Int32          True      False       True
        Property IsReadOnly                      False System.Boolean        True      False       True
        Property IsFixedSize                     False System.Boolean        True      False       True
        Property SyncRoot       {4/12/2022 6:03:53 PM} System.Object         True      False       True
        Property IsSynchronized                  False System.Boolean        True      False       True
    #>
    [Alias('iter->Prop')]
    # [OuptputType('[System.Management.Automation.PSMemberInfoCollection[[System.Management.Automation.PSPropertyInfo, System.Management.Automation]]]')]
    [CmdletBinding()]
    param(
        # Object[s] to enumerate
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )
    begin {
        [Collections.Generic.List[Object]]$items = @()
    }
    process {
        $items.AddRange( $InputObject )
    }
    end {
        $items.psobject.properties | Sort-Object Name -Descending
    }
}

