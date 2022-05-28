if ( $publicToExport ) {
    $publicToExport.function += @(
        'Goto-EditInVSCode'
    )
    $publicToExport.alias += @(

        'GoCode' # 'Goto-EditInVSCode'

    )
}

function Goto-EditInVSCode {
    <#
    .synopsis
        open file in vs code: minimal, always works, [zeroDependency]
    .description
        currently only opens 1 file. Invokes with start to properly spawn a window
    .notes
        future:
        - [ ] open directories
        - [ ] flag 'reuse' or 'newwindow'
    .example
        PS> gi foo.ps1 | GoCode
    .example
        PS> GoCode (~/foo/bar.ps1
    .link
        Ninmonkey.Console\Goto-EditInVSCode
    .link
        Ninmonkey.Console\Goto-Module
    #>
    [Alias('GoCode')]
    [OutputType('System.Void')]
    [CmdletBinding()]
    param(
        # file to open as text, or FileInfo
        [ValidateNotNull()]
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        $Path,

        # open file on a specific line number
        [Parameter(Position = 1)]
        [int]$LineNumber
    )
    begin {}
    process {

        if ($null -eq $Path) {
            throw 'Path Cannot be $Null'
        }
        if ( [string]::IsNullOrWhiteSpace( $Path )  ) {
            throw 'Path Is Blank'
        }
        if ( Test-Path $Path ) {
            $binCode = Get-Command 'code.cmd' -CommandType Application | Select-Object -First 1



            & $binCode @(
                '--goto'
                Get-Item -ea stop $Path | Join-String -DoubleQuote
            )
        }
    }
    end {}
}

