using namespace System.Collections.Generic

#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'newNumericFormatString'
        'splitCulture'
        'Resolve-CultureInfo'
        'Format-ObjectAsCulture'
    )
    $publicToExport.alias += @()
}

function newNumericFormatString {
    <#
    .SYNOPSIS
        future: auto complete needs Completer to show 'int' but return 'n0'
    .EXAMPLE
        Integer -PreCount -EndCount
    #>

    param(
        [Parameter(Mandatory)]
        [string]$Stuff
    )
    Write-Warning "nyi;
        future: auto complete needs Completer to show 'int' but return 'n0'"

}
function Resolve-CultureInfo {
    <#
    .SYNOPSIS
        partial names to an instance
    #>
    [alias('findCultureInfo')]
    param()
    throw 'NYI'

}

function splitCulture {
    <#
    .synopsis
        just directly pass text to Culturinfo class 'dev.nin.CultureInfo.Summary'
    #>
    param(
        [Parameter(ValueFromPipeline)]
        [Globalization.CultureInfo]$Culture
    )
    process {

        # $cults | ForEach-Object {
        $Part1, $part2, $Part3, $part4 = $_.EnglishName -replace '[\(\),]', ';' -split ';'
        [pscustomobject]@{
            'PSTypeName' = 'dev.nin.CultureInfo.Summary'
            Target       = $_
            FullName     = $_.EnglishName
            Part1        = $Part1
            Part2        = $part2
            Part3        = $Part3
            part4        = $part4
        }
        # } | Format-List
    }
}

function Format-ObjectAsCulture {
    <#
    .synopsis
        sugar to convert cultures
    .description
       .
    .NOTES
        todo: arg completers
        [1] humanized name to object
        [2] humanized format strings
    .example
          .
    .outputs
          [string | None]

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$InputObject
    )

    begin {
        CultInfo
    }
    process {
        $InputObject | ForEach-Object {
            $Obj = $_
            $Obj.ToString( $FormatStr, $CultInfo )
        }

    }
    end {
    }
}