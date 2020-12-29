using namespace System.Management.Automation
function Get-NativeCommand {
    <#
    .synopsis
        wrapper that returns Get-Item on a native command
    .description
    .example
        # if you want an error when multiple options are found
        PS> Get-NativeCommand python -OneOrNone

    .example
        # note: this is important, $cmdArgs to be an array not scalar for '@' usage

        $binPy = Get-NativeCommand python
        $cmdArgs = @('--version')
        & $binPy @cmdArgs
    .example
        PS> # conditionally set profile if commands are available

        if((Get-NativeCommand fd) -and (Get-NativeCommand fzf)) {
            'both fd and fzf found!'
            $ENV:FZF_DEFAULT_COMMAND = 'fd'
        }

    #>
    [cmdletbinding()]
    param(
        # Name of Native .exe Application
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$CommandName,

        # One or None: Raise errors when there are more than one match
        [Parameter()][switch]$OneOrNone
    )

    process {
        try {
            # $query = Get-Command -Name $CommandName -All  a -CommandType Application
            $query = Get-Command -Name $CommandName -All -CommandType Application -ea Stop
            | Sort-Object Name

        } catch [CommandNotFoundException] {
            # not so nice error will default to:
            #   > The term 'fake' is not recognized as a name of a cmdlet, function, script file, or executable program
            Write-Error "ZeroResults: '$CommandName'"
            return
        }

        if ($OneOrNone -and $query.Count -gt 1) {
            $query | Format-Table -Wrap -AutoSize -Property Name, Version, Source
            Write-Error "OneOrNone: Multiple results for '$CommandName'"
            return
        }

        if ($query.Count -gt 1) {
            $query = $query | Select-Object -First 1
        }

        Write-Debug "Using Item: $($query.Source)"

        $query
    }

}


# for pester:
if ($false) {
    $binPy = Get-NativeCommand python

    # this is important, needs to be an array not scalar for '@' usage
    $cmdArgs = @('--version')
    & $binPy @cmdArgs

    $bin = Get-NativeCommand 'python' -Debug # no erro
    hr
    & $bin @('--version')
    $x = Get-NativeCommand 'python' -OneOrNone -Debug # should error
    hr
    $x = Get-NativeCommand 'pythfon' -OneOrNone # should error
}

# $t = Get-NativeCommand 'fake'
# $t
# Get-Command - sdfs
# Get-NativeCommand -Verbose
# $a = Get-NativeCommand python #-ea Continue
# $a