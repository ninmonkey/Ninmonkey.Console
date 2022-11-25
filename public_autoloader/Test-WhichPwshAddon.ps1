#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Test-WhichPwshAddon'
    )
    $publicToExport.alias += @(

    )
}

function envInfo.fromProcess {
    # Collect only wanted properties, drop the rest
    $Obj = $Input
    $procSplat = @{
        ErrorAction = 'ignore'
        Property = 'CommandLine', '*descr*', '*file*', '*versiono*', 'Path', 'Name', 'Parent', 'MainModule', '*name*'
    }
    $Obj | Select-Object @procSplat
}

# dirty. needs cleanup.
<#
class PwshAddonEnvInfo {
    hidden [hashtable]$_cached = @{}
}

function New-WhichPwshAddon {
    [PwshAddonEnvInfo]
}

#>


    # (ps -id $PID).Parent | Select-Object @sSplat

function _collectProcFamilyTree {
    # If not specified, uses current PID
    # future: add members without cmdlet overhead for speed
    param(
        [Parameter()]
        [Alias('InputObject')]
        [ArgumentCompletions('(ps -id $PID)')]
        [object]$InitialProcess

        # [hashtable]$Options = @{}
    )
    # $Config = mergeHashtable

    $InitialProcess ??= ps -Id $PID
    $Config = @{
        MaxDepth = 10
    }

    $next = $InitialProcess
    $Depth = 0

    while($null -ne $next) {

        $next
        | envInfo.fromProcess
        | Add-Member -NotePropertyName 'Depth' -NotePropertyValue $Depth -PassThru -Force -ea Ignore

        $next = $next.parent
        $Depth++;
        if($Depth -gt $Config.MaxDepth) { $next = $Null }
    }


}
$script:___t_wpa = @{
    familyTree = _collectProcFamilyTree -InputObject (ps -id $PID)
}
write-warning "mid-write: $PSCommandpath"
function Test-WhichPwshAddon {
        <#
    refactor to merge with

      $script:____promptMiniCache ??= @{
                FinalRender           = ''
                ModulesString         = Get-Module *editor*, *service* | Sort-Object Name
                | Join-String -sep ', ' { '{0} = {1}' -f @(
                        $_.Name, $_.Version )
                }
                EditorServicesRunning = if ( (Get-Module 'EditorServicesCommandSuite', 'PowerShellEditorServices.Commands', 'PowerShellEditorServices.VSCode').count -gt 2 ) {
                    'ES჻ '
                } else {


                }
                EditorName            = (Get-Process -Id $pid).Parent.name
                ExtensionVersion      = & 'code.cmd' --list-extensions --show-versions | Select-String '(ms-vscode.power|powerquery)' -Raw | Join-String -sep ', '
            }
    #>

    [Alias('__find_which_pwsh_extension')]
    [CmdletBinding()]
    param(

    )
    $family = $script:___t_wpa.familyTree
    $EditServicesDLL = $psEditor.GetType().Assembly.Location | gi #-match 'ms-vscode.powershell-preview'


    $meta = @{
        FamilyTree = $family
        IsNotAnyEditor = 'nyi: -not $PSEditor and no extensions'
        IsIvy = 'nyi'
        IsCode = 'nyi'
        IsAny = 'nyi'
        IsPSEditor = $PSEditor
        PwshEdition_Dll = $PSEdition.GetType().Assembly.Location
        EditorServices_Dll = $EditServicesDLL

        Is = @{
            WT = 'nyi'
            AddonPreview = $EditServicesDLL.FullName -match 'ms-vscode.powershell-preview'
            AddonRegular = ($EditServicesDLL.FullName -match 'ms-vscode.powershell') -and ($EditServicesDLL.FullName -notmatch 'ms-vscode.powershell-preview')
            AddonAny = $null

            # C:\Users\cppmo_000\.vscode\extensions\ms-vscode.powershel
            # ms-vscode.powershell-preview
            AnyExtension = 'nyi'
        }

    }
    $meta.Is.AddonAny = $meta.Is.AddonPreview -or $meta.Is.AddonRegular

    [pscustomobject]$meta

    # ms-vscode.powershell-preview

}


