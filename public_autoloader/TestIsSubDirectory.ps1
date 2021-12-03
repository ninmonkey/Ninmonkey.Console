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
       .over-engineered, I was curious if other providers would still match
    .notes
        todo:
            assert args are actually containers
    .example
          Test-IsSubdirectory 'c:\' (gi .)
          Test-IsSubdirectory '~' (gi .)
    .link
        Ninmonkey.Console\Test-IsContainer
    #>
    [outputtype([system.boolean])]
    [CmdletBinding()]
    param(
        [alias('Directory')]
        [Parameter(Mandatory, Position = 0)]
        [object]$Child,

        [Parameter(Mandatory, Position = 1)]
        [object]$Parent
    )

    begin {}
    process {
        try {
            $Short = Get-Item -ea stop $Child
            $Long = Get-Item -ea stop $Parent
            Test-IsDirectory $short
            Test-IsDirectory $long
        }
        catch {
            throw "InvalidArguments: $_"
        }
        @(
            $long -like "${short}*"
            $long -match (ReLit $short)
        ) | Where-Object { $_ -eq $true }

        $false; return
    }
    end {

    }
}
