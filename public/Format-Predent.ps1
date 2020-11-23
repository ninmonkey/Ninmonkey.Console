
function Format-Predent {
    <#
    .synopsis
        Adds indentation to code, ex: to post on a forum
    .description
        .
    .example
        PS> Get-Clipboard | Format-Indent | Set-Clipboard
    .notes
        Maybe a more descriptive name is 'Format-Predent' ?
    #>
    [alias('Format-Indent')]
    [CmdletBinding(DefaultParameterSetName = "fromPipe")]
    param (
        [Parameter(
            ParameterSetName = 'fromParam',
            Mandatory, Position = 0, HelpMessage = 'text to transform')]
        [Parameter(
            ParameterSetName = 'fromPipe',
            Mandatory, ValueFromPipeline, HelpMessage = 'text to transform')]
        [string[]]$Text,

        [Parameter(HelpMessage = 'Number of spaces to indent')]
        [uint]$TabWidth = 4
    )

    begin {
        $allLines = [list[string]]::new()
        # $indentString = "`n", (' ' * $TabWidth) -join ''
        $indentString = (' ' * $TabWidth) -join ''
    }
    process {
        # format entire file at once
        foreach ($line in $Text) {
            $allLines.Add( $line )
        }
    }
    end {
        $splat_JoinString = @{
            OutputPrefix = "`n$indentString"
            Separator    = "`n$indentString"
        }

        $allLines -split '\r?\n' | Join-String @splat_JoinString
    }
}
