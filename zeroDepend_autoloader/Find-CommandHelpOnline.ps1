if ( $publicToExport ) {
    $publicToExport.function += @(
        '_nod_Find-CommandHelpOnline'
        'ConvertTo-Jsonify'
    )
    $publicToExport.alias += @(
        'Hon' # ' _nod_Find-CommandHelpOnline
        'nod.Hon' # '_nod_Find-CommandHelpOnline'
    )
}


# save to module
function _nod_Find-CommandHelpOnline {
    <#
    .SYNOPSIS
        search for command help online.
    .NOTES
        This is the terse, simplified version for no dependency

        ex. this will break
            Hon 'getcommand'
    .EXAMPLE
        gcm 'get-command' | hon
        'get-command' | hon

    .example
        (Get-Module SomeModule | % ExportedCommands).keys
        | Utility\at 3 | hon


    #>
    [alias('Hon', 'nod.Hon')]
    param()
    Get-Command $Input | Select-Object -First 1 | Get-Help -Online
}



