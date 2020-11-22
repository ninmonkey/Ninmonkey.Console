function Format-HashTable {
    <#
    .synopsis
        consistently format hashtables/PSCO objects
    .description
        You can pipe from 'Sort-Hashtable' to 'Format-Hashtable'
    .example
        > $hash = @{ name = 'Jack'; species = 'Cat'; age = 12 }
        > $hash | Format-Hashtable

            age: 12
            name: Jack
            species: Cat

        > $hash | Format-Hashtable SingleLine

            @{age=12; name=Jack; species=Cat}

        > $hash | Format-Hashtable Table

            Name                           Value
            ----                           -----
            species                        Cat
            age                            12
            name                           Jack

    .notes
        Currently only formats a depth of 1

        future:
            display abbreviation for nested values

            PS> $hash = @{app='pip'; meta=@{a=3} }
                | Format-HashTable SingleLine

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
            Position = 0, HelpMessage = "format as line or format-pair"
        )]
        [ValidateSet('SingleLine', 'Table', 'Pair')]
        [string]$FormatMode = 'Pair',

        [Parameter(
            ParameterSetName = "FromPipe",
            Mandatory, ValueFromPipeline, HelpMessage = 'Object'
        )]
        [hashtable]$InputHash,

        [Parameter(HelpMessage = "Sort Keys?")][switch]$NoSortKeys,

        [alias('AsString')]
        [Parameter(HelpMessage = "Force Format-Table to render, so Write-Debug prints as expected")]
        [switch]$Force
    )

    begin {
        # Format-HashTable: Can't use it here, self-referencing
        $PSBoundParameters | Format-Table |  Out-String -w 9999 | Write-Debug
    }

    Process {
        $InputHash.GetType().Name | Label 'InputObject type' |  Write-Debug

        if ($InputHash -is 'System.Collections.Specialized.OrderedDictionary' ) {
            # Write-debug 'sorted!'
            $SortedHash = $InputHash
        } else {
            if ($NoSortKeys) {
                $SortedHash = $InputHash
            } else {
                $SortedHash = $InputHash | Sort-Hashtable
            }
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
                # future: allow overriding args for performance
                $formatted = $InputHash
                | Format-Table -Wrap -AutoSize
                if ($Force) {
                    $formatted | Out-String -Width 9999
                } else {
                    $formatted
                }
                break
            }
            'SingleLine' {
                "$([pscustomobject]$SortedHash)"
                break
            }
            default {
                throw "ShouldNeverReach: FormatMode = '$FormatMode'"
                break
            }
        }
    }
}

<#
for tests:
@{name = 'cat'; } | Format-HashTable Table
#>