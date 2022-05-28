if ( $publicToExport ) {
    $publicToExport.function += @(
        'Goto-Module'
        'RemoveModule'
        'ImportModule'
    )
    $publicToExport.alias += @(

        'GoModule' # 'Goto-Module'
        'PopModule' # 'RemoveModule'
        'PushModule' #  'ImportModule'

    )
}

function Goto-Module {
    <#
    .synopsis
        Goto the directory of the Module
    .example
        PS> goModule PSKoans
    .link
        Ninmonkey.Console\ZD-GoCode
    #>
    [Alias('GoModule')]
    [CmdletBinding()]
    param(
        # any valid module name
        [Parameter(Position = 0, Mandatory)]
        [string]$ModuleName,

        # Force import
        [switch]$Force
    )
    if ($Force) {
        Import-Module -Scope Global -Name $ModuleName -Force | Out-Null
    }
    if (!(Get-Module $ModuleName)) {
        Write-Warning 'Module has not been imported: Use -Force to force the import'
        return
    }
    Push-Location ((Get-Module $ModuleName).Path | Split-Path )
    "PushTo -> $(Get-Location)" | Write-Information

    #    Module Not Loaded, use -Force to force the import
}


function RemoveModule {
    #sugar for faster testing
    [Alias('PopModule'
        # ,'Off'
    )]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ArgumentCompletions('uGit', 'Posh-Git', 'Ninmonkey.Console', 'Dev.Nin', 'Ninmonkey.Profile')]
        [string[]]$Name
    )
    Write-Debug "ImportModule: -> '$Name'"
    Remove-Module -Name $Name
}
function ImportModule {
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

        [switch]$Force,

        [hashtable]$Options = @{}
    )
    begin {
        # $Config = $Config | Ninmonkey.Console\Join-Hashtable -OtherHash $Options
        $importModuleSplat = @{
            Scope = 'global'
        }

        if ($Force) {
            $importModuleSplat['Force'] = $Force
        }

    }
    process {
        foreach ($Name in $ModuleName) {
            Write-Debug "ImportModule: -> '$Name'"
            Import-Module @importModuleSplat -Name $Name
        }
    }
}
