function Get-NinTypeData {
    <#
    .synopsis
        helper utility for Get-TypeData
    .example
        Get-NinTypeData 'system.io.fileinfo' | format-list
    .example
        # List current type names
        PS> Get-NinTypeData -List 'System.*'
        PS> Get-NinTypeData -List
    .example
        PS> Get-NinTypeData 'System.IO.FileInfo' 'DefaultProperties'
        PS> Get-NinTypeData 'System.IO.FileInfo' 'All'
        PS> Get-NinTypeData 'System.IO.FileInfo' 'Members'
        PS> Get-NinTypeData 'System.IO.FileInfo' 'Summary'
    #>
    param(
        # Which type[s] to find?
        # future: Pass type as instance or by name
        [Parameter(Mandatory, Position = 0)]
        [string[]]$TypeName,

        # List types only, skip exporting data
        [Parameter()][switch]$List,

        # Output Mode
        [Parameter(Position = 1)]
        [ValidateSet('DefaultProperties', 'All', 'Members', 'Summary')]
        [string]$OutputMode = 'DefaultProperties'
    )

    $PropList = @{}
    $PropList.Default = @(
        'DefaultDisplayProperty'
        'DefaultDisplayPropertySet'
        'DefaultKeyPropertySet'
    )

    if ($List) {
        Get-TypeData -TypeName $TypeName
        | Select-Object -ExpandProperty TypeName
        | Sort-Object
        return
    }

    switch ($OutputMode) {
        'All' {
            Get-TypeData $TypeName
            break
        }
        'Members' {
            $td = Get-TypeData $TypeName
            $td.Members.GetEnumerator() | ForEach-Object {
                $Key = $_.Key
                $Value = $_.Value
                H1 "Member: $Key"
                $Value | Format-List
            }
            break
        }
        'Summary' {
            $td = Get-TypeData $TypeName
            $td.psobject.Properties | Where-Object Name -Match 'default' | ForEach-Object {
                $meta = [ordered]@{
                    Name     = $_.Name
                    Value    = $_.Value
                    TypeName = $_.TypeNameOfValue

                }
                [pscustomobject]$meta
            } | Format-List
            break

        }
        'DefaultProperties' {
            Get-TypeData $TypeName | Select-Object -Property $PropList.Default
            break
        }
        default {
            throw "Mode NYI: '$OutputMode'"
        }
    }
}
if ($false -and 'enabledTests') {


    H1 'default'
    $a = Get-NinTypeData 'System.IO.FileInfo' DefaultProperties
    $a | Format-List

    H1 'All'
    $b = Get-NinTypeData 'System.IO.FileInfo' All
    $b | Format-List

    H1 'Members'
    $c = Get-NinTypeData 'System.IO.FileInfo' Members
    $c | Format-List

    hr

    H1 'Default (from $all)'
    $b.psobject.Properties | Where-Object Name -Match 'default'
    hr
    $b.psobject.Properties | Where-Object Name -Match 'default' | ForEach-Object {
        $meta = [ordered]@{
            Name     = $_.Name
            Value    = $_.Value
            TypeName = $_.TypeNameOfValue

        }
        [pscustomobject]$meta
    } | Format-List

    if ($false -or 'runtest') {
        $out = Get-NinTypeData 'System.IO.FileInfo'


        $out.DefaultDisplayPropertySet | Format-List

    }
}