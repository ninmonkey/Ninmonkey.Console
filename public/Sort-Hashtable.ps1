function Sort-Hashtable {
    <#
    .synopsis
        return a new, sorted hash using Keys or Values
    .description
        basic hash sortingwrapper for re-use
    .example
        PS> # examples:
        $hash1 = @{ name = 'Jack'; species = 'Cat'; age = 12 }

        Sort-Hashtable $hash1 Key

        $hash1 | Sort-Hashtable -Descending
        $hash1 | Sort-Hashtable Value
        $hash1 | Sort-Hashtable Value -Descending
    .notes
    Does it ever make sense to return enumeration, not a non-ordered-hashtable ?

    see also:

        - [about_Hashtables](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables)
    #>
    [CmdletBinding(DefaultParameterSetName = 'FromParam')]
    param (
        # Hashtable to sort
        [Parameter(ParameterSetName = 'FromParam', Mandatory, Position = 0)]
        [Parameter(ParameterSetName = 'FromPipe', Mandatory, ValueFromPipeline)]
        [hashtable]$InputHash,

        # Sort by key or value?
        [Parameter(ParameterSetName = 'FromParam', Position = 1)]
        [Parameter(ParameterSetName = 'FromPipe', Position = 0)]
        [ValidateSet('Key', 'Value')]
        [String]$SortBy = 'Key',

        # Sort by Descending?
        [Parameter()][switch]$Descending

        # would it ever
        # [Parameter(HelpMessage = "return hash or ordered hash?")][switch]$NotOrdered
        # ?
    )
    begin {}
    Process {
        $OrderedHash = [ordered]@{}

        $splatSort = @{
            Descending = $Descending
            Property   = $SortBy
        }

        $InputHash.GetEnumerator() | Sort-Object @splatSort
        | ForEach-Object {
            $OrderedHash.Add( $_.Key, $_.Value )
        }
        $OrderedHash
    }
    end {}
}
