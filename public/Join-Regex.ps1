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
        [Parameter()]
        [string[]]$Regex,

        # list of literal text values that are combined as a Logical OR
        [alias('LiteralText', 'Lit', 'String')]
        [Parameter()][string[]]$Text
    )

    begin {
        # if ([string]::IsNullOrWhiteSpace($Text) -and [string]::IsNullOrWhiteSpace($Regex)) {
        if ( $null -eq $Text -and $null -eq $Regex) {
            Write-Error 'Requires at least one of -TextLiteral or -Regex parameter'
            return
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
        $Regex_Final = $finalItems
             | Join-String @splat_FinalJoin
             | Join-String -f "({0})" # mostly redundant


        Write-Debug "Regex: Merged literals: $Regex_MergedLiteral"
        Write-Debug "Regex: Merged Regex: $Regex_MergedRegex"
        Write-Debug "Regex: Merged all: $Regex_Final"
        Write-Debug "`$Regex = $Regex_Final"

        # something was wip then went on a tangent
        # 'final regex := {0}' -f $( $Rregex_final)
        # 'regex {0}' -f $( $Rregex_final)
        # # write-verbose
        # $gray1 = .9 * 255
        # $gray2 = .7 * 255
        # $gray3 = .5 * 255
        # $gray4 = .3 * 255


        # $c = @{
        #     fgBright = $PSStyle.Foreground.FromRgb($gray1, $gray1, $gray1)
        #     fg       = $PSStyle.Foreground.FromRgb($gray2, $gray2, $gray2)
        #     fgDim    = $PSStyle.Foreground.FromRgb($gray3, $gray3, $gray3)
        #     fgDim2    = $PSStyle.Foreground.FromRgb($gray4, $gray4, $gray4)
        #     bgBright = $PSStyle.Background.FromRgb($gray1, $gray1, $gray1)
        #     bg       = $PSStyle.Background.FromRgb($gray2, $gray2, $gray2)
        #     bgDim    = $PSStyle.Background.FromRgb($gray3, $gray3, $gray3)
        #     bgDim2    = $PSStyle.Background.FromRgb($gray4, $gray4, $gray4)
        # }

        # @(
        #     $
        # )
        # "${fg:gray90}"
        # "${fg:gray70}"
        # "${fg:gray70}"
        # "${fg:gray90}"

        # '𝄚 gcm join-regex | editfunc -PassThru | % File  | % fullname'


        return $regex_Final
    }
    end {

    }
}
