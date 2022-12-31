using namespace System.Collections

if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'ConvertTo-RegexLiteral'
        'ConvertTo-RegexLiteral.v1'
    )
    $script:publicToExport.alias += @(
        'RegexLit' # 'ConvertTo-RegexLiteral
    )
}


function ConvertTo-RegexLiteral {
    <#
    .SYNOPSIS
        Converts text to regex-escaped literals
    .EXAMPLE
        ls $ENv:UserProfile | %{ RegexLit $_ } | Join-String -sep '|' { $_ }
        ## or
        ls .. -Depth 2 | group Extension | % Name | Join-string -sep '|' { RegexLit -end $_ }
    .NOTES

    .LINK
        ConvertTo-RegexLiter
    #>
    [Alias('RegexLit')]
    [OutputType('System.String')]
    [CmdletBinding(DefaultParameterSetName = 'FromPipeline')]
    param(
        # Input Text
        [Alias('InputObject')]
        # [Parameter( Mandatory, Position = 0, ParameterSetName = 'FromParam')]
        # [Parameter( Mandatory, ValueFromPipeline, ParameterSetName = 'FromPipeline')]
        # Maybe command line ewill resolve easier without mandatory
        [Parameter( ValueFromPipeline, ParameterSetName = 'FromPipeline')]
        [string[]]$TextInput,

        # starts With the anchor ^
        [switch]$StartsWith,

        # starts With the anchor $
        [switch]$EndsWith,

        # Fully surround the final pattern in parenthesis
        [Alias('Parenthesis')]
        [switch]$Enclose
    )
    begin {}

    process {
        foreach ($line in $TextInput) {

            @(
                if ($Enclose) { '(' }
                if ($StartsWith) { '^' }
                [Regex]::Escape( $Line )
                if ($EndsWith) { '$' }
                if ($Enclose) { ')' }
            ) -join ''
        }
    }
}



function ConvertTo-RegexLiteral.v1 {
    <#
    .synopsis
        my original function.  sugar to quickly escape values to thier regex-literal
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
    [alias(
        # 'ReLit',
        # 'RegexLiteral'
    )]
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
            }
            elseif ($AsRipgrepPattern) {
                [regex]::Escape($_) -replace
                '\\ ', ' '
            }
            elseif ($AsVSCode) {
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
