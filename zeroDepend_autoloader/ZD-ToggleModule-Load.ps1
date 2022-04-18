if ( $publicToExport ) {
    $publicToExport.function += @(
        'ZD-RemoveModule'
        'ZD-ImportModule'
    )
    $publicToExport.alias += @(
        'Get-StopWatch' # ZD-RemoveModule
        'stopWatch' # ZD-RemoveModule
    )
}

function ZD-RemoveModule {
    #sugar for faster testing
    [Alias('PopModule'
        # ,'Off'
    )]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompletions('uGit', 'Posh-Git', 'Ninmonkey.Console', 'Dev.Nin', 'Ninmonkey.Profile')]
        [string[]]$Name
    )
    Remove-Module -Name $Name
}
function ZD-ImportModule {
    #sugar for faster testing
    [Alias(
        'PushModule'
        # ,'On'
    )]
    param(
        [Alias('Name')]
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompletions('uGit', 'Posh-Git', 'Ninmonkey.Console', 'Dev.Nin', 'Ninmonkey.Profile')]
        [string[]]$ModuleName,

        [hashtable]$Options = @{}
    )
    begin {
        $Config = $Options

    }
    process {
        foreach ($Item in $ModuleName) {
            Import-Module $Name -Scope global
        }
    }
}
