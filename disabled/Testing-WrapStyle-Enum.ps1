$Config = @{
    FastCacheLoad = $true
    TestFormatEnum = $false
}
if($Config.FastCacheLoad) {
    . (gi 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Ninmonkey.Console\public_autoloader\Format-WrapText.ps1' -ea stop)
} else {
    Import-Module Ninmonkey.Console -Force | out-null
}

if($True) {
    H1 'header'
    $StyleList | UL | Label 'enum [WrapStyle]'
    $StyleList = [WrapStyle] | Get-EnumInfo | ForEach-Object name | Sort-Object

    H1 'invoke without args'
    H1 -fg purple '---- unwrap'
    Label 'Type' 'No args, no join'
    Label 'Code' ' .. | wrapText'
    $StyleList | ForEach-Object {
        $Style = [WrapStyle]$_
        'a'..'c' | wrapText -style $Style
    }
    # function _joinBy {
    #     [scriptBlock]
    # }

    H1 -fg purple '---- none'
    H1 -fg purple '---- unwrap'
    $StyleList | ForEach-Object {
        $Style = [WrapStyle]$_
        Label '[WrapStyle]::' $Style -sep ''
        'a'..'c' | wrapText -style $Style | UL
    }

    function _showExample {
        # todo: actual pipeline invoke passing variable to it
        # instead of $input hack
        param(
            [Alias('SB', 'ScriptBlock')]
            [scriptBlock]$JoinByScriptBlock
        )
        if ( -not $JoinByScriptBlock ) {
            $Input; return;
        }
        $Input | & $JoinByScriptBlock
    }

    @(
  gi . | % Name | wrapText PwshMember -a 'zip'
  gi . | % Name | wrapText PwshMember -a 'ToString()'
) | ul

    H1 -fg purple '---- unwrap'
    $StyleList | ForEach-Object {
        $Style = [WrapStyle]$_
        Label '[WrapStyle]::' $Style -sep ''
        'a'..'c' | wrapText -style $Style | UL
    }


    'a'..'e'
    | _showExample -ScriptBlock { $input | UL }

    0..4
    | _showExample -ScriptBlock { $input | UL }



    & {
        H1 -fg white -bg purple 'No Args'
        $StyleList | ForEach-Object {
            $Style = [WrapStyle]$_
            # this could be wrapText itself, but to prevent confusion
            'a'..'c' | wrapText -style $Style
        }
    }
    & {
        H1 -fg white -bg purple 'One, Two'
        $StyleList | ForEach-Object {
            $Style = [WrapStyle]$_
            Label '[WrapStyle]::' $Style -sep ''
            'a'..'c' | wrapText -style $Style -Arg1 'One' -Arg2 'Two'
        }
    }


    # H1 -fg purple '---- unwrap'
    # $StyleList | ForEach-Object {
    #     $Style = [WrapStyle]$_
    #     # this could be wrapText itself, but to prevent confusion
    #     Label '[WrapStyle]::' $Style -sep ''
    #     'a'..'c' | wrapText -style $Style | UL
    # }

    if($Config.TestFormatEnum) {
        $ErrorActionPreference = 'stop'

        H1 -bg white -fg purple 'As -PassThru'
        [System.ConsoleColor] | _fmt_enumSummary -PassThru
        [System.ConsoleColor]::Red | _fmt_enumSummary -PassThru
        'System.ConsoleColor' | _fmt_enumSummary -PassThru

        H1 -bg white -fg purple 'As'
        [System.ConsoleColor] | _fmt_enumSummary
        [System.ConsoleColor]::Red | _fmt_enumSummary
        'System.ConsoleColor' | _fmt_enumSummary

        $ErrorActionPreference = 'continue'

    }

    0..4
    | wrapText Dunder
    | wrapText PwshVariable
    | wrapText RegexNamedGroup -Argument1 'Stuff'
    | wrapText PwshStaticMember -arg 'Invoke()'
}