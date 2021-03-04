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
        Automatically filters CommandType -- Application
            (not hardcoding *.exe. Maybe this makes it portable?)
            This is good for an accurate -OneOrNone
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
        # List NonUnique commands to resolve OneOrNone

        Get-NativeCommand -List python
            # list of paths here...

        # Select Specific command

        $uniquePath = Get-NativeCommand 'Python' -List
        | % Source | Out-Fzf

        # now it works
        Get-NativeCommand -OneOrNone $uniquePath

    .example
        PS> # conditionally set profile if commands are available

        # if 'less' pager is installed, configure powershell to use it
        if(Get-NativeCommand -TestAny less) {
            $Env:Pager = 'less'
        }

    .example
        PS> Configure only if both 'fd' and 'fzf' exist, else skip the block

        if ((Get-NativeCommand fd -TestAny) -and (Get-NativeCommand fzf -TestAny)) {
            $ENV:FZF_DEFAULT_COMMAND = 'fd'
        }
    #>
    [cmdletbinding()]
    [OutputType([System.Boolean], [System.Management.Automation.ApplicationInfo])] # null too?
    param(
        # base name or path of a Native .exe Application (passed to Get-Command -Name)
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [object]$CommandName,

        # One or None: Raise errors when there are more than one match
        [Parameter()][switch]$OneOrNone,

        # Returns true if there at least one, or more matches
        [Parameter()][switch]$TestAny,

        # List all matches -- then quit, PassThru?
        [Parameter()][switch]$List
    )

    process {
        try {
            $splat_Gcm = @{
                Name        = $CommandName
                All         = $true
                CommandType = 'Application'
                ErrorAction = 'Stop'
            }
            if ($TestAny) {
                $splat_Gcm.ErrorAction = 'SilentlyContinue'
            }
            # $query = Get-Command -Name $CommandName -All -CommandType Application -ea Stop
            $query = Get-Command @splat_Gcm | Sort-Object Name
        } catch [CommandNotFoundException] {
            Write-Error "ZeroResults: '$CommandName'"
            return
        }
        if ($TestAny) {
            [bool]($query.count -gt 0)
            return
        }

        if ($List) {
            $query
            return
        }


        if ($OneOrNone -and $query.Count -gt 1) {
            $first = $query | Select-Object -First 1
            $first.Source

            Write-Error "OneOrNone: Multiple results for '$CommandName'. -List for details). First was: '$($first.Source)'"
            return
        }

        if ($query.Count -gt 1) {
            $query = $query | Select-Object -First 1
        }

        Write-Debug "Using Item: $($query.Source)"
        $query
    }

}