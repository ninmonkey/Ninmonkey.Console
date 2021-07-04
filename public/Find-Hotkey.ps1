

function Get-Hotkeys {
    <#
    .synopsis
        ancient code, but the output is decent.
    .example
        PS> Get-Hotkeys alt, shift, enter, ctrl

        # these are both
            Get-PSReadLineKeyHandler -Bound | sort Group | rg 'alt|shift|enter|ctrl|$'
            Get-PSReadLineKeyHandler -Bound | sort Group | rg 'alt|shift|enter|ctrl|$' | measure

        # Simplified to:

            Get-Hotkeys alt, shift, enter, ctrl
            Get-Hotkeys alt, shift, enter, ctrl | measure

    .notes

    todo:
        - [ ] remove rg dependency for color
        - [ ] generate unique colors per key names
        - [ ] generate hotkey names autocompleted from parsed results of (get-psreadlinekeyhandler)
            so athat
            Get-Hotkeys al[tab] sh[tab] en[tab]
                As one long string? or as an array ?
        - [ ] arg passing, easy to allow
            $split = $line -match ',' ? ',' : '\s+'
                key1, key3
                key1 key3
        # highlights any matched words


    #>
    [CmdletBinding()]
    param (
        [Parameter(, Position = 0, HelpMessage = "Keys to search for like: 'enter, ctrl'")]
        [string[]]$keys
    )

    $items = $keys -split ','
    "using: $( $items -join ', ' )"
    # Get-PSReadLineKeyHandler -Bound | sort Group | rg 'alt|shift|enter|ctrl|$'

    $regex = $keys
    | ForEach-Object {
        [regex]::Escape( $_.Trim() )
    } | Join-String -Separator '|'

    $regex += '|$'
    Get-PSReadLineKeyHandler -Bound | Sort-Object Group | rg $regex
    'hotkey regex: ', $regex -join '' | Write-Host -ForegroundColor Magenta


}
