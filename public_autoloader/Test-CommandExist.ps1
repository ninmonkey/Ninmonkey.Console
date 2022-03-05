using namespace System.Collections
$script:publicToExport.function += @(
    'Test-CommandExists'
    'Assert-CommandExists'
)
$script:publicToExport.alias += @(
)

function Test-CommandExists {
    [OutputType('System.Boolean')]
    param(
        <#
        .synopsis
            Does command exist? Returns bool
        .notes
            warning: performance wise, it is slow, because of Resolve-CommandName
        .link
            Ninmonkey.Console\Resolve-CommandName
        .link
            Ninmonkey.Console\Assert-CommandExists
        .link
            Ninmonkey.Console\Test-CommandExists
        #>
        [Parameter(mandatory, position = 0)]
        $InputObject
    )

    process {
        try {
            Ninmonkey.Console\Resolve-CommandName -CommandName $InputObject -ea stop
        } catch {
            return $false
        }
        return $true

    }
}
function Assert-CommandExists {
    <#
    .synopsis
        Does command exist? otherwise Raise exception
    .notes
        warning: performance wise, it is slow, because of Resolve-CommandName
    .notes
        Should I return [cmdinfo] on success or nothing? Not unless -PassThru
    .link
        Ninmonkey.Console\Resolve-CommandName
    .link
        Ninmonkey.Console\Assert-CommandExists
    .link
        Ninmonkey.Console\Test-CommandExists
    #>
    param(
        [Parameter(mandatory, position = 0)]
        $InputObject
    )

    process {
        try {
            Ninmonkey.Console\Resolve-CommandName -CommandName $InputObject -ea stop | Out-Null
        } catch {
            throw [System.Exception]"Command could not be found: '$InputObject'"
        }

        # implicit output if it doesn't throw

    }
}
