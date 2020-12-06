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
        Get-NinAppxPackage 'first.*name', 'another.*name', 'third.*name'
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
    .notes
        future: opt-in to compare the *name* field

        - note:

    see also:
        - <https://docs.microsoft.com/en-us/powershell/module/appx/?view=win10-ps>
        - <https://docs.microsoft.com/en-us/windows/win32/appxpkg/troubleshooting>

    #>
    param(
        # Regex to compare against the FullName of the exe
        [Parameter(Mandatory, Position = 0)]
        [string[]]$Regex,

        # GetAppXPackage -AllUsers. (Requires admin)
        [Parameter()][switch]$AllUsers,

        # Return Instances without formatting ?
        [Parameter()][switch]$PassThru
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
        $rawResults = foreach ($curRegex in $Regex) {
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
            $LinkTargetList = $matchingPackages | ForEach-Object InstallLocation | Get-Item -ea Continue | ForEach-Object Target

            # $TargetList = $MatchingExeList.Target
            # $MatchingExeList | Select-Object -ExpandProperty FullName | Get-Item -ea continue

            $returnHash = @{
                'Regex'      = $curRegex
                'App'        = $MatchingPackages
                'ExeList'    = $MatchingExeList
                'TargetList' = $LinkTargetList
            }
            [pscustomobject]$returnHash
        }


        $finalResults = $rawResults | Where-Object { $null -ne $_.App }

        $InstallList = $finalResults.App.InstallLocation | Get-Item -ea Continue
        $LinkList = $installList
        | Where-Object { $null -ne $_.Target }
        | Select-Object -ExpandProperty Target
        | Get-Item -ea continue


        if ($PassThru) {
            $finalResults
            return
        }

        # summarize data
        $finalResults | Select-Object -expand App | Format-List
        $finalResults | Format-List Regex, App, ExeList, TargetList
        $finalResults | Format-Table Regex, App

        H1 'linked to'
        $LinkList | ForEach-Object FullName
    }
    end {
        Write-Warning 'currently does not detect path
    "C:\Program Files\WindowsApps\Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe\StateOfDecay2"
        '
    }
}

# Get-NinAppXPackage 'state.*decay'
# | Tee-Object -var 'lastAppX'
# if ($isVscodeNin) {
#     Get-NinAppXPackage 'state.*decay'
#     | Tee-Object -var 'lastAppX'
# }