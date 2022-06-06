
#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Test-PathsAreEqual'
        'Ensure-CurWorkingDirectory'
    )
    $publicToExport.alias += @(
        '_ensureCwd' # 'Ensure-CurWorkingDirectory'
        'Ensure->Cwd' # 'Ensure-CurWorkingDirectory'
    )
}

class IsExperimental : Attribute {
    # Cleaner way to have 'NYI' / 'WIP' commands
    [string]$Reason

    IsExperimental([string]$Reason) {
        $this.Reason = $Reason
    }
}

function Test-PathsAreEqual {
    <#
    .synopsis
        convert paths, see if they are equal or not
    .notes
        it definitely worked correct in this situation
        Cwd Verses a Get-Item
            (get-location | Convert-path) -eq (gi $ExpectedPath | Convert-Path)
    #>
    [OutputType( [System.Boolean] )]
    param(
        [Parameter(Position = 0)]
        [object]$Path1,

        [Parameter(Position = 1)]
        [object]$Path2
    )

    [boolean]$is_cwd = (Get-Item $Path1 | Convert-Path) -eq (Get-Item $Path2 | Convert-Path)
    return $is_cwd
}


function Ensure-CurWorkingDirectory {
    [Alias('_ensureCwd', 'Ensure->Cwd')]
    [cmdletBinding()]
    param(
        # Move to dest, if not currently there
        [Alias('Is', 'InputObject', 'PSPath', 'Path')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [Object]$ExpectedPath,

        # toggles enforcing the Dotnet Cwd vs User Cwd
        [Parameter()][switch]$DotnetPath
    )
    begin {
    }

    process {
        if ($DotnetPath) {
            $is_dotnetCwd = $false
            throw "Add Dotnet calls $PSCommandPath"
        }

        # [boolean]$is_cwd = (get-location | Convert-path) -eq (gi $ExpectedPath | Convert-Path)
        $is_cwd = Test-PathsAreEqual -Path1 (Get-Location) -Path2 $ExpectedPath
        "Test: Cwd -Is '$ExpectedPath' ? $is_cwd" | Write-Debug
        if ($Is_cwd) {
            return
        }
        if (! $Is_cwd) {
            Push-Location -Path $ExpectedPath
            Write-Debug "moving:... from $(Get-Location) -> to $($ExpectedPath) "
            Write-Debug "moving to:... $ExpectedPath"

        }
    }
    end {

    }
}
