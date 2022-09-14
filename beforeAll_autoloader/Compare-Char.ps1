if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'compareChar'
        'getCharAt?'
        'compareString'
    )
    $script:publicToExport.alias += @(

    )
}

function compareChar {
    <#
    .SYNOPSIS
        intended to compare two chars/codepoints, if one or both are '', returns false. not enforced.
    .DESCRIPTION
        intended to compare two chars/codepoints, if one or both are '', returns false. not enforced.
    .notes

        see more:
            - [Extract substrings from a string](https://docs.microsoft.com/en-us/dotnet/standard/base-types/divide-up-strings)
            - tut [Using \[StringBuilder\]](https://docs.microsoft.com/en-us/dotnet/standard/base-types/stringbuilder)
            - [Parsing Strings and conversions](https://docs.microsoft.com/en-us/dotnet/standard/base-types/parsing-strings)
            - [string formatting types](https://docs.microsoft.com/en-us/dotnet/standard/base-types/formatting-types)
            - [`IFormattable` Interface](https://docs.microsoft.com/en-us/dotnet/standard/base-types/formatting-types#the-iformattable-interface)
            - [Composite formatting](https://docs.microsoft.com/en-us/dotnet/standard/base-types/composite-formatting)
            - [`StringBuilder` Tutorial](https://docs.microsoft.com/en-us/dotnet/api/system.text.stringbuilder?view=net-6.0#StringAndSB)
            - [Override the ToString method](Override the ToString method)

        todo: format for type [compareChar.CharComparisonResult]

            - hide/dim chars that match
            - dim AreEqual true
            - render uses FormatControlChar
            - missing red end of string where one is not long enough or -eq ''

        todo:

            - [ ] colorize output:

                Offset RawA RawB A B AreEqual
                ------ ---- ---- - - --------
                    0 a    a    a a     True
                    1      e    ␠ e    False
                    2           ␠ ␠     True
                    3                  False

    .EXAMPLE
        PS>  compareString 'a bc de' 'axbc  e  !' | Format-Table

            Offset RawA RawB A B AreEqual
            ------ ---- ---- - - --------
                0 a    a    a a     True
                1      x    ␠ x    False
                2 b    b    b b     True
                3 c    c    c c     True
                4           ␠ ␠     True
                5 d         d ␠    False
                6 e    e    e e     True
                7             ␠    False
                8             ␠    False
                9      !      !    False
                10                  False
    #>

    param([string]$A, [string]$B)

    class CharComparisonResult {
        [string]$RawA
        [string]$RawB
        [string]$A
        [string]$B
        [bool]$AreEqual
    }

    return [CharComparisonResult]@{
        RawA     = $A
        RawB     = $B
        A        = $A | Format-ControlChar
        B        = $B | Format-ControlChar
        AreEqual = ($A -eq $B) -and $B -ne [string]::Empty
    }
}
function getCharAt? {
    # char or none, no errors
    param(
        [string]$InputText = '',
        [int]$Offset
    )
    $Len = $inputText.Length
    if ($Offset -ge $Len) {
        return ''
    }
    # $InputText.IndexOf(
    return $InputText[$Offset]
}
function compareString {
    <#
    .synopsis
        ..
    .EXAMPLE
        PS>  compareString 'abcd' 'abcd' | ? -Not AreEqual
    .EXAMPLE
        PS>  compareString 'a bc de' 'axbc  e  !' | Format-Table

            Offset RawA RawB A B AreEqual
            ------ ---- ---- - - --------
                0 a    a    a a     True
                1      x    ␠ x    False
                2 b    b    b b     True
                3 c    c    c c     True
                4           ␠ ␠     True
                5 d         d ␠    False
                6 e    e    e e     True
                7             ␠    False
                8             ␠    False
                9      !      !    False
                10                  False


    #>
    param([String]$TextA, [String]$TextB )
    $MaxLen = [math]::max( $TextA.Length, $TextB.Length )
    0..($maxLen-1) | ForEach-Object {
        $curOffset = $_
        $curA = getCharAt? -InputText $TextA -Offset $curOffset
        $curB = getCharAt? -InputText $TextB -Offset $curOffset
        compareChar -A $CurA -B $CurB
        | Add-Member -NotePropertyName 'Offset' -NotePropertyValue $curOffset -PassThru -Force
    }
}