

function StringTo-Object {
    <#
    .synopsis
        Allows you to use Format-Wide -Column on any strings
    .description
        This creates a [psco] where `.Name` returns the original string.
        This is sometimes useful. For example: Piping text to Format-Wide with columns.
        Regular strings will only
        This is simalar to using Select:

        PS> $stringList  | select-object -prop  @{ l='Name'; e= { $_.ToString() } }
    .example
        # Compare these two.
        # $string:List | format-wide
        PS> Get-Command | select -ExpandProperty Name | fw -AutoSize
        PS> Get-Command | select -ExpandProperty Name | fw -Column 9
        # output: always 1 column wide
        PS> Get-Command | select -ExpandProperty Name | StringTo-Object | fw -AutoSize
    .notes
        should the name be ConvertFrom-String ?
    #>
    [Alias('StrObject')]
    param(
        # convert strings to objects
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$StringList
    )

    process {
        $StringList | Select-Object @{
            Name = 'Name'
            e    = { $_ }
        }
    }
}
function Format-StringWide {
    <#
    note: refactor

    Instead, a custom [string] using [Format-Wide formatdata] might
    give a better user experience
    #>
    param(
        # List of strings to display
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$String,

        # Use 'Format-Wide -Autosize'
        [Parameter()][switch]$AutoSize
    )

    begin {
        $objList = [list[string]]::new()
    }

    process {
        $objList.add(

        )
    }
    end {}
}


Write-Warning "Latest version is in: Ninmonkey.Console"


if ($null -eq $lastPropFilter) {
    Get-Module * -ListAvailable -ov 'lastGetModule'
    | Select-Object Name, Tags, *ver* -ov 'lastPropFilter'
    | Format-Table

} else {
    'cachedResults in $lastPropFilter, $lastGetModule, $allTags'
}

$allTagNames = $lastGetModule
| Select-Object -ExpandProperty Tags
| Sort-Object -Unique

H1 'manual Fw -9'
$allTagNames | Select-Object | ForEach-Object {
    [pscustomobject]@{
        Name = $_
    }
} | Format-Wide -Column 9


<#
this does not format wide, so it's not *just* prop test.
$alteredNames = $allTagNames | ForEach-Object {
    $_ | Add-Member -NotePropertyName 'Name' -NotePropertyValue ($_.ToString()) -PassThru
}
$alteredNames | Format-Wide -AutoSize

#>