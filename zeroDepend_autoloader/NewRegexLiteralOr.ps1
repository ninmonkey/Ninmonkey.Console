if ( $publicToExport ) {
    $publicToExport.function += @(
        'New-RegexLiteralOr'

    )
    $publicToExport.alias += @(


        'NewRegexLiteralOr'  # 'New-RegexLiteralOr'
        '.regex.LitOr'  # 'New-RegexLiteralOr'
        'ReLitOr'  # 'New-RegexLiteralOr'

        # 'newRegexLiteralOr' # 'New-RegexLiteralOr'

        # non-existing, experimimenting
        # '.regexLit.OrExpression' # 'New-RegexLiteralOr'
        # '.regexLit_OrExpression' # 'New-RegexLiteralOr'

    )
}

function New-RegexLiteralOr {
    <#
    .SYNOPSIS
        minimalism to
    .example
        @( 'c:\data', 'c:\foo\bar.ps1' )
        | newRegexLiteralOr

        # outputs:

        ((c:\\data)|(c:\\foo\\bar\.ps1))

        # outputs:
        $Env:AppData

    .example
        $regexRequired = @(
            gi $Env:AppData
            gi $Env:LOCALAPPDATA
        ) | newRegexLiteralOr
        $regexExclude = @(
            gi $Env:UserProfile\Documents
        ) | newRegexLiteralOr

        $Path -match $regexRequired
        $Path -notmatch $regexExclude


    #>
    [Alias(
        'NewRegexLiteralOr',
        '.regex.LitOr',
        'ReLitOr' # Verses ReLiter
    )]
    param()
    $Input # if you add anything to the func, replace  $input, it's not recommended
    | Join-String -sep '|' -op '(' -os ')' { '({0})' -f @( [Regex]::Escape($_) ) }
}
