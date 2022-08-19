# return
function _detetermineJsonify-Diagnostics_Process {
    <#
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic?view=net-6.0
    #>
    # never called



    Hr
    $propNames.GetEnumerator() | ForEach-Object {
        H1 $_.Key
        $_.Value | Sort-Object
        # | Join-String -sep ', '
    }

    H1 'test remaining props to pick some'
}
<#
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
#>
