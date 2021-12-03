#Requires -Version 7
$script:publicToExport.function += @(
    'Test-IsSubDirectory'
)
$script:publicToExport.alias += @(

)


function Test-IsSubDirectory {
    <#
    .synopsis
        Is X a subdir of Y?
    .description
       .over-engineered, I was curious if other providers would still work

    .notes
        todo:
            - [ ] [switch] Allow Non-Existing paths
            - [ ] another parameter set, value from pipeline would be the parent?child?
    .example
          Test-IsSubdirectory 'c:\' (gi .)
          Test-IsSubdirectory '~' (gi .)
    .link
        Ninmonkey.Console\Test-IsContainer
    #>
    [outputtype([system.boolean])]
    [CmdletBinding()]
    param(
        # child to test, can be text or file
        [alias('Directory')]
        [Parameter(Mandatory, Position = 0)]
        [object]$Child,

        # potential parent
        [Parameter(Mandatory, Position = 1)]
        [object]$Parent
    )

    begin {}
    process {
        # try {
        try {
            $conditions = @(
                $Short = Get-Item -ea ignore $Child
                $Long = Get-Item -ea ignore $Parent
                Test-IsDirectory $short
                Test-IsDirectory $long
                # silly compare, but it works.
                ( $long -like "${short}*") -or (
                    $long -match ([regex]::Escape( $short ))
                )
            ) | Where-Object { $_ }

        } catch {
            # Write-Error -ea continue -Category 'InvalidArgument' -Message "Bad directory: $_"
            Write-Debug $_
            $false; return
        }

        [bool](Test-All $Conditions)
    }
    end {

    }
}
