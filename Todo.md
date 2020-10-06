# Todo

- [ ] convert formatting functions from <- `C:\Users\cppmo_000\Documents\2020\dotfiles_git\powershell\NinCore-CLI-formatting.ps1`
- [ ] convert formatting functions  <- from `C:\Users\cppmo_000\Documents\2020\powershell\NinLibs\Nin-Style\StyleNin_module.ps1`

## quick

Label

-   [ ] add `$null -eq $runeList | Label 'IsNull?'`

```ps1
# these should work. might need [object] and special test?
$true | Label 'Foo'
$null -eq $runeList | Label 'IsNull?'
```

## auto completer

### Support nested commands, like `git` and `dotnet`

```ps1


  dotnet [add | build | test | ... ]
```

## misc

-   [ ] `rg` wrapper (default `env vars` are set in my profile)
    -   [ ] add `Env Vars` for `rg`, `less`, `gitbash`, etc
-   [ ] pretty print [json.tool cli args](https://docs.python.org/3/library/json.html#command-line-options)
-   [ ] [jq docs](https://stedolan.github.io/jq/manual/), [jq tutorial](https://stedolan.github.io/jq/tutorial/)

```powershell
$foo | python -m json.tool
... | jq
```
