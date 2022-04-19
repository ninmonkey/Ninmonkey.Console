function Join-Regex {
    <#
    .synopsis
        Combine patterns, creating a new OR regex pattern
    .description
        It allows merging literals and patterns as an or, in one call

        Like when you use
            🐒>  Ls . | ?{ $_.FullName -match 'dotfiles|config' }
        or
            🐒> $Path = gi $Env:UserProfile
                $Regex = [regex]::escape( $Path )
                Ls . | ?{ $_.FullName -match $Regex }

        See ./Join-Regex.tests.ps1 for more

    .example
        PS> ls env: | ?{ $_.Value -match (Join-Regex -LiteralText $Env:USERPROFILE) }

    .example
        PS> Get-ChildItem env: | Where-Object {
            $_.Value -match ( Join-Regex -LiteralText $Env:USERPROFILE  )
        } | rg -i $(Join-Regex -LiteralText $Env:USERPROFILE, '$')

    .notes
        future:

            - [ ] a way to simplify regex merged with a literal, instead of an OR, like:
                    $PathAsLiteral = [regex]::escape( $Path )
                    $Regex = '^' + $PathAsLiteral
                    $Env:PATH -split ';' -match $Regex
                or
                    $env:path -match ('^' + [regex]::escape($Env:USERPROFILE)) # expect false
                    $env:path -split ';' -match ('^' + [regex]::escape($Env:USERPROFILE)) # expect true for several

                It's probably best to just write a second regex generating command
    # maybe related Exception names: 'ArgumentException', 'ParameterBindingException', 'PositionalParameterNotFound', 'PSArgumentException', 'ArgumentException'
    .outputs
        [string]

    #>
    [CmdletBinding()]
    param(
        # list of regex patterns that are combined as a Logical OR
        [Alias('Pattern')]
        [Parameter()][string[]]$Regex,

        # list of literal text values that are combined as a Logical OR
        [alias('LiteralText', 'Lit')]
        [Parameter()][string[]]$Text

    )

    begin {
        if ([string]::IsNullOrWhiteSpace($Text) -and [string]::IsNullOrWhiteSpace($Regex)) {
            throw 'Requires at least one of -TextLiteral or -Regex parameter'
        }
    }
    process {
        $splat_JoinLiteral = @{
            Separator = '|'
            Property  = { '({0})' -f [regex]::Escape( $_) }
        }
        $splat_JoinRegex = @{
            Separator = '|'
            Property  = { '({0})' -f $_ }
        }
        $splat_FinalJoin = @{
            Separator = '|'
            Property  = { '{0}' -f $_ }
        }

        $Regex_MergedLiteral = $Text | Join-String @splat_JoinLiteral
        $Regex_MergedRegex = $Regex | Join-String @splat_JoinRegex
        $finalItems = @(
            if (! [string]::IsNullOrWhiteSpace($Text)) {
                $Regex_MergedLiteral
            }
            if (! [string]::IsNullOrWhiteSpace($Regex)) {
                $Regex_MergedRegex
            }
        )
        $Regex_Final = $finalItems | Join-String @splat_FinalJoin

        Write-Debug "Regex: Merged literals: $Regex_MergedLiteral"
        Write-Debug "Regex: Merged Regex: $Regex_MergedRegex"
        Write-Debug "Regex: Merged all: $Regex_Final"
        Write-Debug "`$Regex = $Regex_Final"
        return $regex_Final
    }
    end {

    }
}
