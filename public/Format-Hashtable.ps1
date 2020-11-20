function Format-HashTable {
    <#
    .synopsis
        consistently format hashtables/PSCO objects
    .example
        > @{ name = 'Jack'; species = 'Cat'; age = 12 } | Format-HashTable -SingleLine
        > @{ name = 'Jack'; species = 'Cat'; age = 12 } | Format-HashTable

        @{species=Cat; age=12; name=Jack}
        @{species=Cat; age=12; name=Jack}
    .notes
        todo: [1]
            summarize types

                PS> $hash = @{app='pip'; meta=@{a=3} }
                PS> $hash | Format-HashTable

            should return
                @{meta=[Hashtable]; app=pip}

        todo: [2] nested formattting
            - [param]: -OutString:
                wraps call with $stuff | out-string
                before hitting out-debug or other streams


            nested summary
                PS> $hash = @{app='pip'; meta=@{a=3} }
                PS> $hash | Format-HashTable

            [a] should return
                @{meta=@{a=3}; app=pip}
            [b] or
                @{
                    meta = @{ a = 3 }
                    app  = pip
                }

            [c] or

                [Hashtable]:
                    meta = @{a=3}
                    app  = pip

    #>
    [CmdletBinding(DefaultParameterSetName = "FromPipe")]
    param (
        [Alias('Format-Hash')]
        [Parameter(
            ParameterSetName = "FromPipe",
            Mandatory = $false,
            Position = 0, HelpMessage = "format as line or format-pair"
        )]
        [ValidateSet('SingleLine', 'Table', 'Pair')]
        [string]$FormatMode,

        [Parameter(
            ParameterSetName = "FromPipe",
            Mandatory, ValueFromPipeline, HelpMessage = 'Object'
        )]
        [hashtable]$InputHash,

        [Parameter(HelpMessage = "Sort Keys?")][switch]$NoSortKeys
    )

    process {
        if ($NoSortKeys) {
            $SortedHash = $InputHash
        } else {
            $SortedHash = $InputHash | Sort-Hashtable
        }
        Switch ($FormatMode) {
            'Pair' {
                $SortedHash.GetEnumerator() | ForEach-Object {
                    $splatPair = @{
                        Label = $_.Key
                        Text  = $_.Value
                    }
                    Label @splatPair
                }
                break
            }
            'Table' {
                $SortedHash | Format-Table
                break
            }
            'SingleLine' {
                "$([pscustomobject]$SortedHash)"
                break
            }
            default {
                "$([pscustomobject]$SortedHash)"
                break
            }
        }
    }
}

#Import-Module Ninmonkey.Console -Force
$hash1 = @{ name = 'Jack'; species = 'Cat'; age = 12 }
$hash1 | Sort-Hashtable -Descending
| Format-HashTable Pair
hr
$hash1 | Sort-Hashtable
| Format-HashTable Pair -NoSortKeys
