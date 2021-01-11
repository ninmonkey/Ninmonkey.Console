function Format-HashTable {
    <#
    .synopsis
        consistently format hashtables/PSCO objects
    .description
        You can pipe from 'Sort-Hashtable' to 'Format-Hashtable'
        final output is a single line (joined by newlines)
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
        # Format Mode: SingleLine, Table, Pair. ( Default is 'pair' )
        [Alias('Format-Hash')]
        [Parameter(ParameterSetName = "FromPipe", Position = 0)]
        [ValidateSet('SingleLine', 'Table', 'Pair')]
        [string]$FormatMode = 'Pair',

        # Input hash
        [Parameter(ParameterSetName = "FromPipe", Mandatory, ValueFromPipeline)]
        [hashtable]$InputHash,

        # optional title name
        [Parameter()]
        [String]$Title,

        # Skip sorting keys?
        [Parameter()][switch]$NoSortKeys,

        # Force Format-Table to render (so Write-Debug prints as expected) -AsString
        [Alias('AsString')]
        [Parameter()][switch]$Force
    )

    begin {
        # Format-HashTable: Can't use it here, self-referencing
        $PSBoundParameters | Format-Table |  Out-String -w 9999 | Write-Debug

        # $FinalText = [list[string]]::new()[System.Text.StringBuilder]
        # see: [StringBuilder] AppendLine, AppendJoin, Append
        # I was having problems with stringbuilder, quick hack using regular string
        [string]$strFinalText = [string]::Empty
    }

    Process {
        $InputHash.GetType().Name | Label 'InputObject type' |  Write-Debug

        if ($InputHash -is 'System.Collections.Specialized.OrderedDictionary' ) {
            Label 'isOrderedDictionary' 'true' | Write-Debug
            $SortedHash = $InputHash
        } else {
            if ($NoSortKeys) {
                $SortedHash = $InputHash
            } else {
                $SortedHash = $InputHash | Sort-Hashtable
            }
        }


        # hashtables don't enumerate, so starting title *does* go in process
        if (! [string]::IsNullOrWhiteSpace( $Title )) {
            # do⇽┐no notes ┤
            # warning, .Append was
            $strFinalText += Label "# $Title #" -sep '' -Label '' -fg blue -LinesBefore 3
            $strFinalText += "`n"
            $strFinalText += Label "# $Title #" -LinesBefore 3 #-sep '' -Text '' -fg blue -LinesBefore 3

            # [void]$sbFinalString.AppendLine( $out.ToString() )
            # (
            #     # "`n", (Label "# $Title #" -sep '' -Text '' -fg blue -LinesBefore 3) -join ''
            # )

        }

        # enumerate values
        Switch ($FormatMode) {
            'Pair' {
                $strFinalText += $SortedHash.GetEnumerator() | ForEach-Object {
                    $splatPair = @{
                        Label = $_.Key
                        Text  = $_.Value
                    }
                    Label @splatPair
                }
                # [void]$sbFinalString.AppendLine( $out )
                break
            }
            'Table' {
                # future: allow overriding args for performance
                $formatted = $InputHash
                | Format-Table -Wrap -AutoSize
                if ($Force) {
                    $strFinalText += $formatted | Out-String -Width 9999
                } else {
                    $strFinalText += $formatted
                }
                # [void]$sbFinalString.AppendLine( $strFinalText )
                break
            }
            'SingleLine' {
                $strFinalText += "$([pscustomobject]$SortedHash)"
                # [void]$sbFinalString.AppendLine( $strFinalText )
                break
            }
            default {
                throw "ShouldNeverReach: FormatMode = '$FormatMode'"
                break
            }
        }
    }
    end {
        # $sbFinalString.ToString() | Join-String -sep "`n" | Label -sep '' | Out-String -Width 999 | Write-Debug
        H1 'made it'
        # $sbFinalString.ToString()
        $strFinalText -join "`n"
    }
}

<#
for tests:
# @{name = 'cat'; } | Format-HashTable Table
#>
hr
@{name = 'cat'; } | Format-HashTable -Title 'Title' -Verbose