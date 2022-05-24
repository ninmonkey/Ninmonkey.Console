function Find-TabExpansionCommand {
    <#
    .synopsis
        Find tab expansion hooks
    .description
        .

    .example
        PS>
    .notes
        .
    #>
    # [alias('Find-TabExpansion')]
    param (
        [Parameter()][switch]$UseGrep
    )
    begin {
        throw 'Obsolete'
    }
    process {
        # $Target = gi -ea stop $InputObject # Yes? No?
        $meta = @{
            ChocolateyProfile     = $ChocolateyProfile
            ChocolateyTabSettings = $ChocolateyTabSettings
        }
        $Found = Get-Command 'tab*' -All | Where-Object {
            $_.CommandType -ne 'Application' -and $_.Source -ne 'PSWriteHtml'
        } | Sort-Object Name
        $meta;
        Hr 4
        $found
        Hr
        'next: search function:provider'
    }
}
