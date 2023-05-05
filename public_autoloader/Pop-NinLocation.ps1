#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Pop-NinLocation'
    )
    $publicToExport.alias += @(
        'nin.Popd' # 'Pop-NinLocation'
    )
}

function  Pop-NinLocation {
    <#
    .synopsis
        this proxy greatly simplififes trying to modify Stacks in user's scope
    #>
    [Alias(
        'nin.Popd' # popd was conflicts with default
    )]
    [CmdletBinding()]
    param(
        # [switch]$PassThru,
        [string]$StackName


        #    [-PassThru]
        #    [-StackName <String>]
        #    [<CommonParameters>]
    )

    $splat_pop = @{
        StackName = $StackName ?? 'ninLocationStack'
    }


    try {
        Pop-Location @splat_pop -PassThru:$PassThru -ea stop
        | Label 'pop <- ' | Write-Information
    } catch {
        if ( -not $_.Exception.Message -match 'Cannot find location stack' ) {
            throw $_
        }

        return
    }

}