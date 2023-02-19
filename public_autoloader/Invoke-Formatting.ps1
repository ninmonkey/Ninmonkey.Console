#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'InvokeFormat_ps1' # 'fmt.ps1
    )
    $publicToExport.alias += @(
        'fmt.ps1' # 'InvokeFormat_ps1'
    )
}

function InvokeFormat_ps1 {
    <#
    .synopsis

    .DESCRIPTION
        see also: the hotkey that formats the currrent CLI without needing clipboard

        Ability to pipe to invoke-formatter was added in <PSScriptAnalyzer 1.21.0>  (or older?)

    #>
    [Alias('fmt.ps1')]
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        # future: input type object, could allow script blocks
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory,ValueFromPipeline)]
        $InputObject,
        # [switch]$Short
        # [switch]$PassThru
        [hashtable]$Options = @{}
    )
    begin {
        $Config = mergeHashtable -OtherHash $Options -BaseHash @{

        }
    }
    process {
        write-warning 'InvokeFormat_ps1 is NYI'
        if( [string]::IsNullOrWhiteSpace( $InputObject ) ) {
            return
        }
        # $source = $InputObject -as 'string'
        $InputObject
        | PSScriptAnalyzer\Invoke-Formatter
    }
    end {
    }
}

write-warning "quick test: always keybinding ctrl+shift+p: $PSCommandPath"

write-warning "next: psreadline func to call current buffer"


Set-PSReadLineKeyHandler -Key 'ctrl+shift+p' -ScriptBlock {
    Get-Clipboard | Invoke-Formatter | Set-ClipBoard -PassThru
}
