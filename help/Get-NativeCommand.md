```ps1
if ($false) {
    $binPy = Get-NativeCommand python

    $cmdArgs = @('--version', '-I')
    & $binPy @cmdArgs

    $bin = Get-NativeCommand 'python' -Debug
    # no error

    & $bin @('--version')
    $x = Get-NativeCommand 'python' -OneOrNone -Debug
    # error if there's more than one python found

    $x = Get-NativeCommand 'python_does_not_exist' -OneOrNone
    # errors: 0 results

    # does not care whether aliases or functions have a name collision, like
    # alias 'ls'
    Get-ChildItem --all --color=always -1

    New-Alias 'ls' -Value 'Get-ChildItem'
    function ls { 'do nothing' }

    Get-NativeCommand 'ls' -OneOrNone
    # success!


    # error: Get-ChildItem: A positional parameter cannot be found that accepts argument '-1'.

    # but this works
    Invoke-NativeCommand 'ls' -args '--all', '--color=always', '-1'
    # and so does
    Invoke-NativeCommand 'ls' -args '--all', '--color=always', '-1' -OneOrNone

}
```