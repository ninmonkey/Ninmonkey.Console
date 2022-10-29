if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'Format-WrapText'
        '_fmt_enumSummary'
    )
    $script:publicToExport.alias += @(
        'wrapText'
    )
}

enum WrapStyle {
    Under
    Dunder
    RegexOptional
    RegexNamedGroup
    PwshStaticMember
    PwshMember
    PwshVariable
    Html_Href # <a href=1>0</a>
    Markdown_Link # [0](1)
    Markdown_DetailsSummary
    # PwshVarOptionalItem
    Parenthesis
    Bracket
    Brace
}

function _fmt_enumSummary {
    <#
    .SYNOPSIS
        kind of sugar for quickly viewing enum and format as one
    #>
    param(
        # return names, else render?
        [Parameter()][switch]$PassThru,

        [Alias('Name')]
        # todo: EnumTypeCompletion
        [Parameter(Position = 0, ValueFromPipeline)]
        [Object]$InputEnum
    )
    process {
        if ($InputEnum -is 'string') {
            $Target = $InputEnum -as 'type'
        } else {
            $Target = $InputEnum
        }
        $einfo = $Target | Get-EnumInfo | Sort-Object Name


        if ($null -eq $einfo) {
            Write-Error "could not resolve '$InputEnum', a '$($InputEnum.GetType().FullName)' as $($Target.GetType().FullName)"
            return
        }

        if ($PassThru) {
            return $einfo
        }

        $LabelMessage = 'enum {0}' -f @(
            $Target | shortType -NoColor
        )

        $einfo | ForEach-Object Name
        | UL
        # | Label "enum [$($Target.FullName)]"
        | Label $LabelMessage


    }
}

function Format-WrapText {
    <#
    .SYNOPSIS
        sugar allows composable custom strings
    .link
        Ninmonkey.Console\Format-ShortStr
    .link
        Ninmonkey.Console\Format-WrapText
    #>

    [Alias('wrapText')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$InputText,

        # maybe param 1?
        [Parameter(Position = 0, Mandatory)]
        [WrapStyle]$Style,

        # Optional prefix string
        [Alias('op')]
        [Parameter()]
        [string]$Prefix,

        # Optional suffix string
        [Alias('os')]
        [Parameter()]
        [string]$Suffix,

        # First argument (when styles have parameters)
        [Alias('Param1', 'A')]
        [Parameter()]
        [string]$Argument1,

        # Second argument (when styles have parameters)
        [Alias('Param2', 'B')]
        [Parameter()]
        [string]$Argument2

    )
    begin {
        if ( $Null -eq $Prefix ) {
            $Prefix = '('
        }
        if ( $Null -eq $Suffix) {
            $Suffix = ')'
        }
        switch ($Style) {
            ([WrapStyle]::Brace) {
                $Prefix = '{'
                $Suffix = '}'
            }

            # ([WrapStyle]::PwshVariableOptionalItem) {
            #     # ([WrapStyle]::PwshVariableOptionalItem) {
            #     $Prefix = '($'
            #     $Suffix = ')?'
            #     $Prefix = @(
            #         '(?<'
            #         $Argument1 ?? 'Name'
            #         '>'
            #     ) -join ''
            # }
            ([WrapStyle]::Bracket) {
                $Prefix = '['
                $Suffix = ']'
            }
            ([WrapStyle]::Parenthesis) {
                $Prefix = '('
                $Suffix = ')'
            }
            ([WrapStyle]::Under) {
                $Prefix = '_'
                $Suffix = ''
            }
            ([WrapStyle]::Dunder) {
                $Prefix = '__'
                $Suffix = ''
            }
            ([WrapStyle]::RegexOptional) {
                $Prefix = '('
                $Suffix = ')?'
            }
            ([WrapStyle]::PwshVariable) {
                $Prefix = '$'
                $Suffix = ''

            }
            ([WrapStyle]::RegexNamedGroup) {
                $Prefix = @(
                    '(?<'
                    $Argument1 ?? 'Name'
                    '>'
                ) -join ''
                $Suffix = ')'
            }
            # old way tried to do prefix in one go, instead
            # 'base'.'bar'
            ([WrapStyle]::PwshMember) {
                # $One.Two
                # $Prefix = @(
                #     '$'
                #     $Argument1 ?? 'Name'
                # ) -join ''
                $Suffix = @(
                    '.'
                    $Argument1 ?? 'Member'
                ) -join ''
            }
            # ([WrapStyle]::PwshMember) {
            #     # $One.Two
            #     $Prefix = @(
            #         '$'
            #         $Argument1 ?? 'Name'
            #     ) -join ''
            #     $Suffix = @(
            #         '.'
            #         $Argument2 ?? 'Member'
            #     ) -join ''
            # }
            ([WrapStyle]::PwshStaticMember) {
                # $One.Two
                $Prefix = @(
                    '$'
                    $Argument1 ?? 'Name'
                ) -join ''
                $Suffix = @(
                    '::'
                    $Argument2 ?? 'Member'
                ) -join ''
            }
            default {
                throw "Unhandled enum value: $($_)"

            }
        }
    }
    process {
        @(
            $Prefix
            $InputText
            $Suffix
        ) -join ''
    }
}
