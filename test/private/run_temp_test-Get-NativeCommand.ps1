Import-Module Ninmonkey.Console -Force | Out-Null
H1 'quick test'


Get-NativeCommand -List 'python'
| Select-Object Name, Source | ForEach-Object Source
hr

H1 'expect OneOrNone: "bat"'
Get-NativeCommand bat -OneOrNone


H1 'expect multiple: "python"'
Get-NativeCommand python -OneOrNone

H1 'test "Out-Fzf" lookup'

Label 'expect multiple'
Get-NativeCommand -List python

# cached just for the test file
Label 'Select specific one'
$fzf_selection ??= Get-NativeCommand -List python | ForEach-Object Source | Out-Fzf

Label 'Now -OneOrNone'
Get-NativeCommand $fzf_selection -OneOrNone

$DoNotMutate = $true
H1 'Test for Less'
if (Get-NativeCommand -Test 'less') {
    if (! $DoNotMutate) {
        $Env:Pager = 'less'
        $Env:LESSARGS = '-R'
    }

    # "Env:Pager: $($Env:Pager)"
    Label 'Env:Pager' $Env:Pager
    Label 'Env:LESSARGS' $Env:LESSARGS

}

H1 'Test: require both "Fd" and "Fzf"'

hr
# if ((Get-NativeCommand fd -TestAny -ea ignore) -and (Get-NativeCommand fzf -TestAny -ea ignore)) {
if ((Get-NativeCommand fd -TestAny) -and (Get-NativeCommand fzf)) {
    'both fd and fzf found!, setting Env Var'
    if (! $DoNotMutate) {
        $ENV:FZF_DEFAULT_COMMAND = 'fd'
    }
    Less 'FZF_DEFAULT_COMMAND' 'fd'
}