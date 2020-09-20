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
        [Alias('Format')]
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
        [hashtable]$InputHash
    )

    process {
        Switch ($FormatMode) {
            'Pair' {
                Write-Warning 'Piping to Format-Pair'
                $InputHash | Format-Pair
                break
            }
            'Table' {
                $InputHash | Format-Table
                break
            }
            'SingleLine' {
                "$([pscustomobject]$InputHash)"
                break
            }
            default {
                "$([pscustomobject]$InputHash)"
                break
            }
        }
    }
}
