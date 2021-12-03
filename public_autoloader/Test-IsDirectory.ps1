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
        Is it a directory, or other container type??'
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
        Ninmonkey.Console\Test-IsSubDirectory
    #>
    [Alias('Test-IsDirectory')] # probably a better name
    [outputtype('System.Boolean')]
    [CmdletBinding()]
    param(
        # File object or path to test
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [Alias('PSPath')]
        [string]$Path
    )
    begin {
    }
    process {
        <#
         #>
        try {
            $item = Get-Item $Path -ea stop
        }
        catch {
            # definitely didn't exist
            Write-Debug 'GI failed'
            $false; return
        }
        $isType = $Item -is 'System.IO.DirectoryInfo'
        $meta = @{
            IsDirInfo   = $isDir
            HasAttr     = $hasAttribute
            IsContainer = [bool]$Item.PSIsContainer

        }

        $hasAttribute = ($item.Attributes -band [IO.FileAttributes]::Directory) -eq [IO.FileAttributes]::Directory
        # you could also do -ne 0 at the end to achieve the same thing
        $hasAttribute = ($item.Attributes -band [IO.FileAttributes]::Directory) -ne 0
        $isType -or $hasAttribute -or ([bool]$Item.PSIsContainer)

        # Wait-Debugger
        return
    }
    end {
    }
}


if ( $false -and (! $publicToExport)) {
    # ...
    Get-Item . | Test-IsDirectory | Should -Be $True
    Get-Item fg:\ | Test-IsDirectory | Should -Be $True
    Test-IsDirectory '.' | Should -Be $True
}
