#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'New-TextObject'
    )
    $publicToExport.alias += @(
        'TextObj'  # 'New-TextObject'
        'To->TextObj'  # 'New-TextObject'


    )
}

function New-TextObject {
    <#
    .synopsis
        sugar for the command line -- ix: [pscustomobject]@{a=1}
    .notes
        .
    .example
        Normally you can't pipe raw strings to FW , and use columns
        🐒> 'a'..'z' | obj | fw -Column 5

            a             b             c             d            e
            f             g             h             i            j
            k             l             m             n            o
    .example
        PS> @{name='cat'} | Obj
    .example
        PS> # some types are a round trip
            $error |  Inspect->ErrorType | obj | dict | obj | dict
    .link
        Ninmonkey.Console\New-NinPSCustomObject
    .link
        Ninmonkey.Console\New-HashtableFromObject
    .link
        Ninmonkey.Console\New-HashtableLookup
    #>
    [Alias('TextObj', 'To->TextObj')]
    [outputtype([System.Management.Automation.PSObject] )]
    [cmdletbinding()]
    param(
        # switched to obj, so strings auto coerce easier
        [parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$InputObject,

        # kwargs
        [hashtable]$Options = @{}

    )
    begin {}
    process {

        if ($InputObject -is 'hashtable') {
            $InputObject['PSTypeName'] = 'DevNin.Obj'
        }
        # future
        # should include when the input is an object?
        $InputObject.GetType().FullName
        | Write-Debug # prints: [System.Collections.Specialized.OrderedDictionary]
        $tinfo = $InputObject.GetType().FullName

        switch ($Tinfo) {
            { $_ -is 'System.String' -or $_ -is 'System.Char' } {

                [pscustomobject]@{
                    PSTypeName = 'DevNin.StringObject'
                    Name       = $InputObject
                }
            }
            default {
                [pscustomobject]$InputObject
            }
        }
    }
    end {
    }
}

if (! $experimentToExport) {
    # ...
}