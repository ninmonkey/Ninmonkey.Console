function Get-EnumInfo {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .example

        PS> [IO.Compression.CompressionMode] | Get-EnumInfo

        #output:
            enum [IO.Compression.CompressionMode]
                Decompress, Compress

    .NOTES
    General notes
    #>

    param(
        [parameter(
            Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'enum as typeinfo instance or string')]
        [String]$InputEnum,

        [parameter(HelpMessage = 'return meta info as an object')]
        [switch]$PassThru
    )
    Process {
        if ($PassThru) {
            throw "left off here, return enum name to mapping hashtable"
            return
        }

        _format_enumPrettyPrint -FormatMode line -InputEnum $InputEnum
    }

}

function _format_enumMetaInfo {
    _format_enumPrettyPrint
}
function _format_enumPrettyPrint {
    <#
    .synopsis
        private func pretty prints enum typename and value names
    .example

        PS> [IO.Compression.CompressionMode] | _format_enumPrettyPrint -Mode 'Line'

        #output:
            enum [IO.Compression.CompressionMode]
                Decompress, Compress

    #>
    param(
        [parameter(
            Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'enum as typeinfo instance or string')]
        # [enum]
        [String]$InputEnum,

        [parameter(
            Position = 1)]
        [validateset('Line', 'Table')]
        [string]$FormatMode = 'Line'
    )
    begin {

        $template = @{
            EnumName = "enum [{0}]`n`t" # 0 = typename
        }

    }
    process {
        # $InputEnum = $InputEnum
        if ($FormatMode -like 'line' ) {

            $typeName = $InputEnum -replace '^System\.', ''
            $x = [enum]::GetNames( $typeName )
            $x | Join-String -sep ', ' -OutputPrefix ($template.EnumName -f $typeName)
            return
        }

        if ($FormatMode -like 'Table' ) {
            throw 'nyi: Format enum as Table'
        }

    }

}
