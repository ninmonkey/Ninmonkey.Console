#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'ConvertTo-EscapedUri'
        'ConvertFrom-EscapedUri'

    )
    $publicToExport.alias += @(
        'Uri->Escape' # 'ConvertTo-EscapedUri'
        'Uri->UnEscape' # 'ConvertFrom-EscapedUri'

    )
}


function ConvertTo-EscapedUri {
    <#
    .synopsis
        sugar to escape/unescape. nothing special
    .EXAMPLE
        PS> ConvertFrom-EscapedUri "Hi - world!.md"
            Hi%20-%20world%21.md

        PS> ConvertFrom-EscapedUri 'Hi%20-%20world%21.md'
            Hi - world!.md\
    .notes
        Should I be useing another method than DataString ?
        See also

            public static string UnescapeDataString(string stringToUnescape);
            public static string EscapeUriString(string stringToEscape);
            public static string EscapeDataString(string stringToEscape);
            public static string HexEscape(char character);
            public static char HexUnescape(string pattern, ref int index);
            public bool UserEscaped { get; }



    #>
    [Alias('Uri->Escape')]
    param(
        # un-escapes the escaped uri
        [Parameter(Position = 0, ValueFromPipeline)]
        [string]$Text
    )

    process {
        return [uri]::EscapeDataString( $Text )
    }

}
function ConvertFrom-EscapedUri {
    <#
    .synopsis
        sugar to escape/unescape. nothing special
    .EXAMPLE
        PS> ConvertFrom-EscapedUri "Hi - world!.md"
            Hi%20-%20world%21.md

        PS> ConvertFrom-EscapedUri 'Hi%20-%20world%21.md'
            Hi - world!.md
    #>
    [Alias('Uri->UnEscape')]
    param(
        # un-escapes the escaped uri
        [Parameter(Position = 0, ValueFromPipeline)]
        [string]$Text
    )

    process {
        return [uri]::UnescapeDataString( $Text )
    }
}

class MinLoggerDestinationConfig {
    # todo: expansion
    # name?
    # [string]$LogName = 'ninmonkey.console-shared'
    # [string]$RootDir = 'H:\data\2022\log_list' # more for the log source?
    [System.IO.FileInfo]$Path

    # [Void] MinLoggerDestination ($x) {

    # }
    # [string]ToString() {
    #     return $this.Path
    # }

}
class MinLoggerConfig {
    # todo: expansion
    # global config
    # [MinLogger]
}

# $logger = [MinLoggerOutConfig]@{
#     LogName = 'ninmonkey.console-shared'
#     RootDir = 'H:\data\2022\log_list'
# }


[hashtable]$script:__ninLog = @{
    LogName = 'min_logger-global'
    RootDir = 'H:\data\2022\log_list'
}
function Get-NinLogOption {

    <#
    .synopsis
        retrieve current config
    .link
        Ninmonkey.Console\Set-NinLogOption
    .link
        Ninmonkey.Console\Get-NinLogOption
    .link
        Ninmonkey.Console\Write-NinLogRecord
    #>
    # todo: use instance of [MinLoggerConfig]
    $state = $script:__ninLog
    return $state
}
function Set-NinLogOption {
    <#
    .synopsis
        minimal wrap
