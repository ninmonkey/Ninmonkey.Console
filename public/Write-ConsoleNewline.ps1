function Write-ConsoleNewline {
    <#
    .synopsis
        minimal function to return variable numbers of newlines
    #>
    [Alias('Br', 'NL', 'LF')]
    param (
        # how many lines?
        [Parameter(Position = 0)]
        [int]$Count = 1
    )
    $Count-- # because '0' still returns a string which implicitly can write a line

    if ($Count -lt 0) {
        return
    }
    ("`n" * $Count) -join ''
}

if ($false) {
    Write-Warning '<Br> todo: move to dynamic pester testing'
    & {
        0..4 | ForEach-Object {
            $res = Br $_
            [ordered]@{
                # Id     = $_
                Count  = $res.Count
                Length = $res.length
            }
            | Format-HashTable -Title $_ SingleLine

        }
    }
}