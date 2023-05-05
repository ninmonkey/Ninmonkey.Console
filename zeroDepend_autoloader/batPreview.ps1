#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'batPreview'
    )
    $publicToExport.alias += @(

    )
}
# recheck 2023-03-11
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

        [switch]$AlwaysRelative,
        # kwargs style extra
        [hashtable]$Options = @{}
    )

    begin {
        $Config = ninmonkey.console\Join-Hashtable -OtherHash $Options -BaseHash @{

        }

        $NameList = [list[string]]::new()
        if ( Get-Command -Name 'fzf' -CommandType Application -ea ignore) {
        } else {
            $PSCmdlet.ThrowTerminatingError('Requires fzf')
        }
    }
    process {
        if ( ninmonkey.console\Test-IsContainer -InputObject $InputPath ) {
            return # bat shouldn't see directories
        }
        $nameList.AddRange( $InputObject )
    }
    end {

        if ($false) {
            & rg -C 5 --column --line-number --no-heading --color=always --smart-case 'bdg'
            | fzf

        }

        # future: is there a clean way to allow directories
        # but have bat not preview them ?
        if ($AlwaysRelative) {
            $NameList
            | StripAnsi | To->RelativePath
            | Where-Object { $null -ne $_ } # Where-IsNotBlank
            | Where-Object { -not ( Test-IsDirectory -InputObject $_ ) }
            | fzf.exe -m --preview 'bat --style=snip,header,numbers --line-range=:200 "{}"'
            return
        }
        $NameList
        | Where-Object { $null -ne $_ } # Where-IsNotBlank
        | Where-Object { -not ( Test-IsDirectory -InputObject $_ ) }
        | fzf.exe -m --preview 'bat --style=snip,header,numbers --line-range=:200 "{}"'

    }
}
