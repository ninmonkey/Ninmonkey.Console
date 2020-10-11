using namespace System.Text

h1 'final'
0..50 | ForEach-Object {
    [char]::ConvertFromUtf32( $_ )
} | ForEach-Object {
    $CurrentLine = $_
    $CurrentLine.enumerateRunes() | ForEach-Object {
        $RuneInfo = $_
        $Codepoint = $RuneInfo.Value
        if ($Codepoint -ge 0 -and $Codepoint -le 0x1f ) {
            $Codepoint += 0x2400
        }
        [char]::ConvertFromUtf32( $Codepoint )
    }

    # $_ -replace '[\x00-\x1f]', '~'
} | Join-String -sep ''

function Format-ControlChar {
    <#
    .synopsis
        Converts unsafe control chars to their symbols, which are safe to print
    .description
        Replaces C0-control codes with their unicode-symbol replacents at u+2400+
    .example
        PS> "`u{00}" | Format-ControlCharSymbol
        # output: ␀
    .notes
        todo:
            - [  ] use string builder for `$finalString`
        better performance:
            - [ ] use string builder, or pipe results directly directly
    #>
    param(
        # [AllowNull()]
        # [AllowEmptyString()]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = "Text to map")]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$InputObject

    )
    begin {
        $uni_range = 0..0x1f
        $uni_increment = 0x2400
        $finalString = ""
        $runeReplace = [Rune]::ReplacementChar
        $runeNull = [char]::ConvertFromUtf32( 0 ) # or "`u{0}" [null]
        $runeNoSign = [char]::ConvertFromUtf32( 0x1f6ab )  # or "`u{1f6ab}" 🚫
    }

    process {
        $InputObject | ForEach-Object {
            $CurrentLine = $_
            $CurrentLine.EnumerateRunes() | ForEach-Object {
                $RuneInfo = $_ # is a [Text.Rune]
                $Codepoint = $RuneInfo.Value
                if ($Codepoint -ge 0 -and $Codepoint -le 0x1f ) {
                    $Codepoint += 0x2400
                }
                [char]::ConvertFromUtf32( $Codepoint )
            }


        }
    }
}

hr
0..50 | ForEach-Object {
    [char]::ConvertFromUtf32( $_ )
} | Format-ControlChar
| Join-String -sep ''


function Format-ControlCharSymbol {
    <#
    .synopsis
        Converts unsafe control chars to their symbols, which is safe to print.
    .description
        Replaces C0-control codes with their unicode-symbol repalcements at u+2400+
    .example
        PS> "`u{00}" | Format-ControlCharSymbol
        # output: ␀
    .notes
        todo:
            - [  ] use string builder for `$finalString`
    #>
    param(
        # [AllowNull()]
        # [AllowEmptyString()]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = "Text to map")]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$InputObject

    )

    begin {
        $uni_range = 0..0x1f
        $uni_increment = 0x2400
        $finalString = ""
        $runeNull = [char]::ConvertFromUtf32( 0 ) # or "`u{0}"
        $runeNoSign = [char]::ConvertFromUtf32( 0x1f6ab )  # or "`u{1f6ab}"
    }
    process {
        <#
        display a null glyph if invoked with null value, or should it

        I forget the reason I didn't simply return on null input
            IIRC it made it easier for users to pass arrays or elements that are/contain null without causing errors ?
            Not allowing null did cause errors in cases where it's unwanted, because this is a weird use case
        #>
        if ([string]::IsNullOrEmpty( $InputObject )) {
            if ($null -eq $InputObject) {
                $InputObject = $runeNull
                # $finalString += "`u{0}" | Format-ControlCharSymbol
            } else {
                $InputObject = $emptyText  # 'empty' # special char for empty ?
            }
            # $finalString += ("`u{0}" | Format-ControlCharSymbol)
            # Write-Warning 'isnullorempty'
            # return
        }


        foreach ($CurText in $InputObject) {
            Label 'Type:' ( $CurText.GetType().Name, $CurText -join ' = ') | Write-Debug
            if ($null -eq $CurText) {
                $CurText = ''

            }
            if ([string]::IsNullOrEmpty($CurText) -or ($null -eq $CurText)) {
                $CurText = $runeNoSign
            }

            $CurText.EnumerateRunes() | ForEach-Object {
                $Codepoint = $_.Value
                if ($Codepoint -in $uni_range) {
                    $Codepoint += $uni_increment
                }

                $rune = [char]::ConvertFromUtf32( $Codepoint )
                $finalString += $rune
            }
        }
    }

    end {
        $finalString | Join-String  -Separator ''
        "FinalString.Length = $($finalString.Length)" | Write-Debug
    }
}
