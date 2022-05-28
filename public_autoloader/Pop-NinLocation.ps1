#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Pop-NinLocation'
    )
    $publicToExport.alias += @(
        'PopD' # 'Pop-NinLocation'
    )
}

function  Pop-NinLocation {
    <#
    .synopsis
        this proxy greatly simplififes trying to modify Stacks in user's scope
    #>
    [Alias(
        'PopD'
        # 'GotoPop' ?
    )]
    [CmdletBinding()]
    param(
        [switch]$PassThru


        #    [-PassThru]
        #    [-StackName <String>]
        #    [<CommonParameters>]
    )

    $StackName = @{
        StackName = 'ninLocationStack'
    }


    try {
        Pop-Location @StackName -PassThru:$PassThru
        | Label 'pop <- ' | Write-Information
    } catch {
        if ( -not $_.Exception.Message -match 'Cannot find location stack' ) {
            throw $_
        }

        return
    }

}