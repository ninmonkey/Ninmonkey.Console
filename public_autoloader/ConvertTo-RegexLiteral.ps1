using namespace System.Collections

if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'ConvertTo-RegexLiteral'
    )
    $script:publicToExport.alias += @(
        'ReLit', 'RegexLiteral'
    )
}

function ConvertTo-RegexLiteral {
    <#
    .synopsis
        sugar to quickly escape values to thier regex-literal
    .description
        .example
        $PS> re 'something'
    .example
        $pattern = re 'something' -AsRipGrep
        rg @('-i', $Pattern)
    .notes
        for syntax, see:

        Rust Flavor:
            https://docs.rs/regex/1.5.4/regex/

        Dotnet Flavor:
            https://docs.microsoft.com/en-us/dotnet/standard/base-types/details-of-regular-expression-behavior#net-engine-capabilities

        Javascript Flavor:
            https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions

    ## variants notes verses default [regex]::escape behavior ##

            see more in 'ConvertTo-RegexLiteral.tests.ps1'

        powershell
            - do; or do not escape ' ' is okay

        vs code / javascript
            - do not escape '#'
            - do not escape ' '
            - must escape '}'

        ripgrep
            - do not escape ' '
                or else escape the '\' before it

    .outputs

    #>
    [alias('ReLit', 'RegexLiteral')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        # Text to convert to a literal
        [Alias('InputObject')]
        [Parameter( Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$Text,

        # Use Regex literal format for ripgrep (Rust)
        [Parameter()][switch]$AsRipgrepPattern,

        # Use Regex literal format for vscode (javascript)
        [Parameter()][switch]$AsVSCode
    )
    begin {
    }
    process {
        $Text | ForEach-Object {
            if ((! $AsRipgrepPattern) -and (! $AsVSCode)) {
                [regex]::Escape($_)
            } elseif ($AsRipgrepPattern) {
                [regex]::Escape($_) -replace
                '\\ ', ' '
            } elseif ($AsVSCode) {
                [regex]::Escape($_) -replace
                '\\ ', ' ' -replace
                '\\#', '#' -replace
                '}', '\}'
            }
        }
    }
    end {
    }
}
