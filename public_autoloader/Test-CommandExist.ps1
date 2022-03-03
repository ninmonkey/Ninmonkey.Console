using namespace System.Collections
$script:publicToExport.function += @(
    'Test-CommandExists'
    'Assert-CommandExists'
)
$script:publicToExport.alias += @(
    'Assert-CommandExists' # 'Test-CommandExists'
)

function Test-CommandExists {
    param(
        <#
        .synopsis
            Does command exist? Returns bool
        #>
        [Paramerter(mandatory, position = 0)]
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
        I'm not sure if I want to return the [cmdinfo] on success or nothing?
    #>
    param(
        [Paramerter(mandatory, position = 0)]
        $InputObject
    )

    process {
        try {
            Ninmonkey.Console\Resolve-CommandName -CommandName $InputObject -ea stop
        } catch {
            throw [System.Exception]"Command could not be found: '$InputObject'"
        }

        # implicit output if it doesn't throw

    }
}
