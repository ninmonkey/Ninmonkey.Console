if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-SpartanVsCode'
        'New-SpartanVsCodeEnvironment'
    )
    $publicToExport.alias += @(

        # 'GoCode' # 'Invoke-SpartanVsCode'

    )
}

function New-SpartanVsCodeEnvironment {
    throw "NYI"
}
function Invoke-SpartanVsCode {
    <#
    .synopsis
        launch "virtualenvs" for vs code
    .example
        Invoke-SpartanVsCode
    .example
        or shared
    .NOTES
        future:
            - [ ] resume command (vs just --adding)
            - [ ] handle paths not existing with a New-SpartanVsCodeEnvironment
    #>
    PARAM(
            [ArgumentCompletions('h:\env')]
            [Parameter()]
            [string]$VEnvRootPath = 'h:\env'


    )

    $user_data_dir = Join-Path 'H:\env\code\env_fast' 'data'
    $addons_dir = Join-Path 'H:\env\code\env_fast' 'addons'
    $c_args = '--extensions-dir', $addons_dir, '--user-data-dir', $user_data_dir, '--profile', 'fast', '--add', (Get-Item $Path)

    & code.cmd @c_args
    Write-Warning ' - [  ] ask is there a better wya to invoke without breaking streams'
    Write-Warning 'find the real one'
}