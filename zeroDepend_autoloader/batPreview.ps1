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
       .
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
        $nameList.AddRange( $InputObject )
    }
    end {
        if ($AlwaysRelative) {
            $NameList
            | StripAnsi | To->RelativePath
            | fzf.exe -m --preview 'bat --style=snip,header,numbers --line-range=:200 {}'
            return
        }
        $NameList
        | fzf.exe -m --preview 'bat --style=snip,header,numbers --line-range=:200 {}'
    }
}
