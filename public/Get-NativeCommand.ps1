using namespace System.Management.Automation

function Get-NativeCommand {
    <#
    .link
        Invoke-NativeCommand
    .synopsis
        wrapper that returns Get-Item on a native command
    .description
        used as a wrapper to native commands, or conditional profile configuration
        like setting "$Env:Pager" to 'bat' or 'less' depending on which is installed
    .notes
        If it is not working correctly, check whether the target binary has 'LinkType' of AppExeCLink.

        Python3 on windows (before installing it) **will** show up under 'gcm' --  but it's actually a link to the windows store (to install it) I was bit by that.
    .example
        # force error when  you want an error when multiple options are found
        PS> Get-NativeCommand python -OneOrNone

    .example
        # you can splat args like the regular invoke

        $binPy = Get-NativeCommand python
        $cmdArgs = @('--version')
        & $binPy @cmdArgs
    .example
        PS> # conditionally set profile if commands are available
        # if 'less' pager is installed, configure powershell to use it
        if(Get-NativeCommand less -ea ignore) {
            $Env:Pager = 'less'
        }

        if((Get-NativeCommand fd -ea ignore) -and (Get-NativeCommand fzf -ea ignore)) {
            'both fd and fzf found!, setting Env Var'
            $ENV:FZF_DEFAULT_COMMAND = 'fd'
        }

    #>
    [cmdletbinding()]
    param(
        # base name or path of a Native .exe Application (passed to Get-Command -Name)
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$CommandName,

        # One or None: Raise errors when there are more than one match
        [Parameter()][switch]$OneOrNone
    )

    process {
        Write-Host -fore magenta 'move to markdown docs, then push'
        try {
            $query = Get-Command -Name $CommandName -All -CommandType Application -ea Stop
            | Sort-Object Name

        } catch [CommandNotFoundException] {
            Write-Error "ZeroResults: '$CommandName'"
            return
        }

        if ($OneOrNone -and $query.Count -gt 1) {
            $query | Format-Table -Wrap -AutoSize -Property Name, Version, Source | Out-String | Write-Debug
            # $query | Format-Table -Wrap -AutoSize -Property Name, Version, Source | Out-String | Write-Host -ForegroundColor yellow

            $first = $query | Select-Object -First 1
            $first.Source

            Write-Error "OneOrNone: Multiple results for '$CommandName'. -Debug for details). First was: '$($first.Source)'"
            return
        }

        if ($query.Count -gt 1) {
            $query = $query | Select-Object -First 1
        }

        Write-Debug "Using Item: $($query.Source)"
        $query
    }

}