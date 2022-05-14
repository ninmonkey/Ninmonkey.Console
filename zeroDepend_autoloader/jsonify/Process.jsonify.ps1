# return
function _detetermineJsonify-Diagnostics_Process {
    <#
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic?view=net-6.0
    #>
    # never called
    function _newISet {
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


    # $all_propNames = (ps )[0].psobject.properties.name
    $p = $propNames = [ordered]@{
        All = $t.psobject.properties.name
    }
    $hs = $hset = @{}
    $hset.All = _newISet $p.All

    $PropNames.Only_64bit = $p.All -match '64$'
    $PropNames.Only_Name = $p.All -match 'Name'
    $PropNames.Only_Type = $p.All -match 'Type'
    $PropNames.Only_Input = $p.All -match 'Input'
    $PropNames.Only_Output = $p.All -match 'Output'
    $PropNames.Only_TypeName = $p.All -match @(
        Join-Regex -LiteralText @(
            'Type', 'BaseType', 'Enum', 'Int', 'double', 'float', 'decimal',
            'string', 'List', 'hash', 'hashtable', 'collection'
        )
    )
    $PropNames.Only_Numeric = $p.All -match @(
        Join-Regex -LiteralText @(
            'Sum', 'total', 'count', 'length', 'height', 'width',
            'Size', 'total', 'max', 'min'
        )
    )

    $hset.Only64 = _newIset $p.Only_64bit

    $PropNames.Only_32Bit = $p.All | Where-Object { $p.All -contains "${_}64" }
    $PropNames.AllExcept_3264Bits = $p.all | Where-Object { $p.Only_64bit -notcontains $_ -and $p.Only_32Bit -notcontains $_ }


    Hr
    $propNames.GetEnumerator() | ForEach-Object {
        H1 $_.Key
        $_.Value | Sort-Object
        # | Join-String -sep ', '
    }

    H1 'test remaining props to pick some'

    Get-Process | s -First 3
    | Select-Object -Property $propNames.AllExcept_3264Bits | Format-Table -AutoSize

    Get-Process | s -First 3
    | Select-Object -Property $propNames.AllExcept_3264Bits | Format-List

    Get-Process | s -First 3
    | Select-Object -Property $propNames.Only_Name | Format-Table -AutoSize

    Get-Process | s -First 3
    | Select-Object -Property $propNames.Only_Name | Format-List

    if ($false) {
        # All_Except32 =
        $t = Get-Process | s -first 1
        $all_propNames = $t.psobject.properties.name

        $props_with64Variant = $all_propNames | Where-Object { $all_propNames -contains "${_}64" }
        $all_except32Bit_propNames | Where-Object { $props_with64Variant -notcontains $_ } | Sort-Object
        $all_except32_or_64 = $al

        $propNames.GetEnumerator() | ForEach-Object {
            H1 $_.Key
            $_.Value | Sort-Object | Format-Wide -Column 4
        }
    }
}
