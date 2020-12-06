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
        $ItemPath = Get-Item $Path
        ($ItemPath.Attributes -band [IO.FileAttributes]::Directory) -eq [IO.FileAttributes]::Directory
    }
}