function Test-IsDirectory {
    <#
    .Synopsis
        Does it include the attribute [IO.FileAttributes]::Directory ?'
    .description
        alias 'isDir'
    .example
        PS> Test-IsDirectory '.'
        # $True

        PS> Test-IsDirectory 'foo.png'
        # $False
    #>
    param(
        # File object or path to test
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [Alias('PSPath')]
        [string]$Path
    )
    process {
        # Todo: see: <https://github.com/SeeminglyScience/dotfiles/blob/7e224fb5fc16998f5956aead620baa4ef9407ebd/PowerShell/Utility.psm1#L231>>
        $ItemPath = Get-Item $Path
        ($ItemPath.Attributes -band [IO.FileAttributes]::Directory) -eq [IO.FileAttributes]::Directory
    }
}
