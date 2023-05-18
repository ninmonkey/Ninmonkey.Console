#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Format-UnicodeCodepoints' # 'Format-UnicodeAsHex'
    )
    $publicToExport.alias += @(
        'Format-UnicodeAsHex' # 'Ninmonkey.Console\Format-UnicodeCodepoints'
        'Format-UniHex' # 'Ninmonkey.Console\Format-UnicodeCodepoints'
    )
}

function Format-UniCodepoints.MinExample {
   # converts text to UnicodeCodepoints, in hex. ie: [Text.Runes[]]
   $Input.EnumerateRunes() | Join-String -f '{0:x2} ' Value
}

function Format-UnicodeCodepoints {
    <#
    .synopsis
        converts text to UnicodeCodepoints, in hex. ie: [Text.Runes[]] as 'ToString('x')
    .description
        if you're on pwsh, it's super simple to view runes ( code-points ) vs chars ( code-units )
    .example
        PS> (gcl) | Format-UnicodeCodepoints
    .EXAMPLE
        # original code started with:
        (gcl -Raw).EnumerateRunes() | Join-String -f '{0:x2} ' Value
        (gcl -Raw).EnumerateRunes() | Join-String -f '{0:x2}' Value
        (gcl -Raw).EnumerateRunes() | Join-String -f '{0:x2}'
    #>
    [Alias('Format-UnicodeAsHex', 'Format-UniHex')]
    [OutputType('System.String') ]
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [Alias('As', 'Format')]
        [ValidateSet(
            'Tiny',
            'Default',
            'PadLeft',
            'PadRight'
        )]
        [string]$OutputMode = 'Tiny',

        [Parameter(ValueFromPipeline)]
        [object[]]$InputObject,

        [int]$PadDigits,

        [hashtable]$Options
    )

    $Config = Ninmonkey.Console\mergeHashtable -OtherHash $Options -BaseHash @{
        PadLeft = $null # 6
        PadRight = $null # 6
        FormatString = '{0,6:x}'
        PadDigits = 6
        ColorFg = ''
        ColorBg = ''
        # sep colors
    }
    $FormatStr = @{
        PrePad10 = '{0,10:x}'
        SingleSpaceSep = '{0:x2} '
        NoSep = '{0:x2}'
    }

    $OutputMode ??= 'Default'

    foreach ($item in $InputObject) {
        switch ($OutputMode) {
            'Default' {
                $Fstr = $FormatStr.SingleSpaceSep # '{0:x2} '
                $Item.ToString().EnumerateRunes()
                | Join-String -f $Fstr -prop Value
            }
            'Tiny' {
                $FStr = $FormatStr.NoSep # '{0:x2}'
                $Item.ToString().EnumerateRunes()
                | Join-String -f $fStr -prop Value
            }
            default { throw "UnhandledOutputMode: $OutputMode" }
        }
    }
    # Normally avoid $Input like the plague because there's a lot of edge cases
    # unless it's really basic, pipe entire line, command
    # $Input.EnumerateRunes()
    # | Join-String -f '{0:x2} ' -prop Value
}
