function Get-NinAppXPackage {
    <#
    .synopsis
        Find AppX packages based on their full path names instead of package name
    .description
        Some packages do not have a descriptive names.


        For example, A game named 'State of Decay 2' is named as 'Dayton'

            Name              : Microsoft.Dayton
            PackageFamilyName : Microsoft.Dayton_8wekyb3d8bbwe
            PackageFullName   : Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe

        But the exe name is descriptive:

            C:\Program Files\WindowsApps\Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe\StateOfDecay2.exe

        This simplifies searching in those cases.
    .example

    PS> Get-AppxPackage '*state*decay*'
        # no results

    PS> Get-NinAppxPackage 'state.*decay'

        Name              : Microsoft.Dayton
        Publisher         : CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US
        Architecture      : X64
        ResourceId        :
        Version           : 2.408.280.0
        PackageFullName   : Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe
        InstallLocation   : C:\Program Files\WindowsApps\Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe
        IsFramework       : False
        PackageFamilyName : Microsoft.Dayton_8wekyb3d8bbwe
        PublisherId       : 8wekyb3d8bbwe
        IsResourcePackage : False
        IsBundle          : False
        IsDevelopmentMode : False
        NonRemovable      : False
        Dependencies      : {Microsoft.VCLibs.140.00.UWPDesktop_14.0.29231.0_x64__8wekyb3d8bbwe}
        IsPartiallyStaged : False
        SignatureKind     : Store
        Status            : Ok

        Regex        App
        -----        ---
        state.*decay Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe

    #>
    param(
        [Parameter(
            Mandatory, Position = 0,
            HelpMessage = 'Regex compares against FullName of the exe')]
        [string[]]$Regex,

        [Parameter(HelpMessage = "GetAppXPackage -AllUsers. (Requires admin)")][switch]$AllUsers,
        [Parameter(HelpMessage = "Return Instances without formatting")][switch]$PassThru
    )

    begin {
        [hashtable]$Cache = @{}

        $Cache.AllAppX = Get-AppxPackage * -AllUsers:$AllUsers
        $Cache.AllBinary = $Cache.AllAppX | ForEach-Object {
            $curAppX = $_
            Get-ChildItem $curAppX.InstallLocation -Recurse *.exe
        }
    }

    process {
        $finalResults = foreach ($curRegex in $Regex) {
            $MatchingExeList = $Cache.AllBinary | Where-Object FullName -Match $curRegex

            $MatchingPackages = $Cache.AllAppX
            | Where-Object {
                $regexInstallPath = [regex]::escape( $_.InstallLocation )
                foreach ($path in $MatchingExeList.FullName) {
                    if ($path -match $regexInstallPath) {
                        return $true
                    }
                }
            }

            $returnHash = @{
                'Regex' = $curRegex
                'App'   = $MatchingPackages
            }
            [pscustomobject]$returnHash
        }

        if ($PassThru) {
            $finalResults
            return
        }

        $finalResults | Select-Object -expand App | Format-List
        $finalResults | Format-Table Regex, App
    }
}
