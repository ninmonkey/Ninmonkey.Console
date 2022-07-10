#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'batPreview'
    )
    $publicToExport.alias += @(

    )
}

function batPreview {
    <#
    .synopsis
        assume piped values are filenames, using bat
    .description
        - gnores directories, they are nonsense in this contxt

        todo
            - [ ] make preview horizontal, and/or
            - [ ]  hotkey toggles preview on and off
    .example
        PS> fd --changed-within 24hours -t f | batPreview

    .example
        # sugar for:
        fd --changed-within 24hours -t f
        | StripAnsi
        | fzf.exe -m --preview 'bat --style=snip,header,numbers --line-range=:200 {}'
    .outputs


    #>
    [CmdletBinding()]
    param(
        # filenames
        [Alias('Name', 'FullName', 'Path')]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$InputObject,

        [switch]$AlwaysRelative
    )

    begin {
        $NameList = [list[string]]::new()
        if ( Get-Command -Name 'fzf' -CommandType Application -ea ignore) {
        } else {
            $PSCmdlet.ThrowTerminatingError('Requires fzf')
        }
    }
    process {
        if ( Ninmonkey.Console\Test-IsContainer -InputObject $InputPath ) {
            return # bat shouldn't see directories
        }
        $nameList.AddRange( $InputObject )
    }
    end {
        # future: is there a clean way to allow directories
        # but have bat not preview them ?
        if ($AlwaysRelative) {
            $NameList
            | StripAnsi | To->RelativePath
            | Where-Object { -not ( Test-IsDirectory -InputObject $_ ) }
            | fzf.exe -m --preview 'bat --style=snip,header,numbers --line-range=:200 "{}"'
            return
        }
        $NameList
        | Where-Object { -not ( Test-IsDirectory -InputObject $_ ) }
        | fzf.exe -m --preview 'bat --style=snip,header,numbers --line-range=:200 "{}"'
    }
}
