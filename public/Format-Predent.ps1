using namespace System.Collections.Generic

function Format-Predent {
    <#
    .synopsis
        Adds indentation to code, ex: to post on a forum
    .description
        .
    .example
        # use clipboard, predent it, then save to clipbard
        PS> Format-Predent
        # the implicit command is:
        PS> Get-Clipboard | Format-Indent | Set-Clipboard

        PS> $sampleText | Format-Predent

        PS> $sampleText | Format-Predent -PassThru
        # prints result
    .notes
    #>
    [alias('Format-Indent')]
    param (
        # Text to transform
        [Parameter(ValueFromPipeline)]
        [string[]]$Text,

        # Number of spaces ot indent
        [Parameter()]
        [uint]$TabWidth = 4,

        # return data instead of writing to clipboard
        [Parameter()][switch]$PassThru
    )

    begin {
        $allLines = [list[string]]::new()
        $indentString = (' ' * $TabWidth) -join ''

        [string]::IsNullOrEmpty( $Text ),
        [string]::IsNullOrWhiteSpace( $Text ) -join ', ' | Label 'nullEmpty? NullWhitespace?' | Write-Debug

        $isFirstItem = $true
    }
    Process {
        Label 'firstProc?' $isFirstItem -bg 'pink' | Write-Debug
        if ($isFirstItem) {
            $isFirstItem = $false
        }

        $PSCmdlet.ParameterSetName | Label 'PSetName' | Write-Debug
        [string]::IsNullOrEmpty( $Text ),
        [string]::IsNullOrWhiteSpace( $Text ) -join ', ' | Label 'nullEmpty? NullWhitespace?' | Write-Debug

        if ([string]::IsNullOrEmpty( $Text )) {
            $allLines.Add( (Get-Clipboard) )
            Label 'Read' 'Clipbard'
        }
        # format entire block of text at once
        foreach ($line in $Text) {
            $allLines.Add( $line )
        }
    }
    end {
        $splat_JoinString = @{
            OutputPrefix = "`n$indentString"
            Separator    = "`n$indentString"
        }

        $results = $allLines -split '\r?\n' | Join-String @splat_JoinString
        if ($PassThru) {
            $results
        } else {
            $results | Set-Clipboard
            Label 'Wrote' 'Clipboard'

        }
    }
}

# "stuff`n`tin`nout" | Format-Predent
# "stuff`n`tin`nout" -split '\r?\n' | Format-Predent

# example/tests
# hr 10
# $sampleEmpty = @( '', '', '')
# $sampleEmpty | Format-Predent
# hr 10
# $sampleText = @'
# a
#     b
# a
# '@
# Format-Predent -Debug

# $sampleText | Format-Predent -Debug
# hr
# $sampleText -split '\r?\n' | Format-Predent -Debug

# hr
# Format-Predent -Text $sampleText -Debug
