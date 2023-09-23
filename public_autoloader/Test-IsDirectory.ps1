#Requires -Version 7
$script:publicToExport.function += @(
    'Test-IsContainer'
)
$script:publicToExport.alias += @(
    'Test-IsDirectory'
)

function Test-IsContainer {
    <#c
    .Synopsis
        Is it a directory, or other container type?'
    .example
        PS> Test-IsDirectory '.'
        # $True

        PS> Test-IsDirectory 'foo.png'
        # $False
        Todo: see: <https://github.com/SeeminglyScience/dotfiles/blob/7e224fb5fc16998f5956aead620baa4ef9407ebd/PowerShell/Utility.psm1#L231>>
            foreach ($item in $pathList) {
            $extraArgs = ($item = Get-Item $Path -ea 0) -and $item.PSIsContainer | ?? { '' } : { '-r' }
            & $code $pathList $extraArgs
        }
    .link
        https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_filesystem_provider?view=powershell-7.3
    .link
        Ninmonkey.Console\Test-IsSubDirectory
    #>
    [Alias('Test-IsDirectory')] # probably a better name
    [outputtype('System.Boolean')]
    [CmdletBinding()]
    param(
        # File object or path to test. False for whitespace or nulls.
        [allowEmptyString()]
        [allowNull()]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [Alias('PSPath', 'Path')]
        [object[]]$InputObject,

        # looser definition ,  use to test containers in providers other than filesystems
        [switch]$IsContainer
    )
    begin {
    }
    process {
        $InputObject | ForEach-Object {
            $TargetItem = $_
            if ($Null -eq $_) {
                return $false
            }
            $item = Get-Item $TargetItem -ea ignore
            if ( [string]::IsNullOrEmpty( $TargetItem )) {
                return $false
            }
            if ($null -eq $item) {
                return $false
            }
            if ($IsContainer -and $Item.PSIsContainer) {
                return $True
            }
            $isType = $Item -is 'System.IO.DirectoryInfo'
            $meta = @{
                IsDirInfo         = $isDir
                HasAttr           = $hasAttribute
                IsContainer       = [bool]$Item.PSIsContainer
                PathTypeContainer = Test-Path -PathType Container -Path $TargetItem
            }
            $meta | Format-Table | Out-String | Write-Debug

            # $hasAttribute = ($item.Attributes -band [IO.FileAttributes]::Directory) -eq [IO.FileAttributes]::Directory
            # you could also do -ne 0 at the end to achieve the same thing
            $hasAttribute = ($item.Attributes -band [IO.FileAttributes]::Directory) -ne 0
            $isContainer = Test-Path -PathType Container -Path $TargetItem

            #  return [bool]:
            $isType -or $hasAttribute -or ([bool]$Item.PSIsContainer) -or $isContainer
        }
    }
    end {
    }
}
