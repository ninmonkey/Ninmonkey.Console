# About: Get-NativeCommand | Ninmonkey.Console
- [About: Get-NativeCommand | Ninmonkey.Console](#about-get-nativecommand--ninmonkeyconsole)
- [Defaults Will Filter Non-Applications](#defaults-will-filter-non-applications)
- [Test for Any Matches](#test-for-any-matches)
- [Conditionally Change Configuration or Env Vars](#conditionally-change-configuration-or-env-vars)
  - [Find any match](#find-any-match)
  - [Set Env Var only if both `fd` and `fzf` exist, otherwise skip the block](#set-env-var-only-if-both-fd-and-fzf-exist-otherwise-skip-the-block)
- [Require Exactly 1 Match, Otherwise Error](#require-exactly-1-match-otherwise-error)
- [Invoking Commands with ArgList](#invoking-commands-with-arglist)
- [List Duplicate Commands / Non Unique](#list-duplicate-commands--non-unique)
- [Resolving Duplicates with `Fzf`](#resolving-duplicates-with-fzf)

# Defaults Will Filter Non-Applications

You don't need to exclude non-applications using `stuff*` or filtering on `.exe`

```ps1
# both are successful
Get-NativeCommand 'ping' -OneOrNone 
(Get-Command 'ping' -All).count -eq 1

# Try to Break It
New-Alias 'ping' -value 'Test-Connection'    
function ping { 'do nothing' }

# Gcm matches unwanted commands (functions, aliases)
(Get-Command 'ping' -All).count -eq 1 # returns False

# this is still successful, still finds only one application
Get-NativeCommand 'ping' -OneOrNone
```

# Test for Any Matches

```ps1
Get-NativeCommand ping -TestAny # true


if (Get-NativeCommand fd -TestAny) {
    $ENV:FZF_DEFAULT_COMMAND = 'fd'
}
```

# Conditionally Change Configuration or Env Vars

## Find any match
```ps1
if(Get-NativeCommand 'Less' -TestAny) {
    # improve the pwsh pager
    $Env:Pager = 'less'
}
```
## Set Env Var only if both `fd` and `fzf` exist, otherwise skip the block

```ps1
if ((Get-NativeCommand fd -TestAny) -and (Get-NativeCommand fzf -TestAny)) {
    $ENV:FZF_DEFAULT_COMMAND = 'fd'
}
```

# Require Exactly 1 Match, Otherwise Error

Fail if there's multiple pythons, to prevent accidents
```ps1
Get-NativeCommand python -OneOrNone
```

# Invoking Commands with ArgList

You can splat args like the regular invoke

```ps1
$binPy = Get-NativeCommand python
$cmdArgs = @('--version')
& $binPy @cmdArgs

$binPing = Get-NativeCommand ping
$cmdArgs = 'google.com', '-n', '1'
& $binPing @cmdArgs
```

# List Duplicate Commands / Non Unique

```powershell
Get-NativeCommand -List python | % Source

C:\Users\<user>\AppData\Local\Programs\Python\Python37-32\python.exe
C:\Program Files (x86)\Python36-32\python.exe
C:\programs\Python34\python.exe
C:\Users\<user>\AppData\Local\Microsoft\WindowsApps\python.exe
```

# Resolving Duplicates with `Fzf`

List all matches, selecting the correct one with `Out-Fzf` or `Out-GridView -PassThru`

```powershell
$uniquePath = Get-NativeCommand 'Python' -List | % Source | Out-Fzf

Get-NativeCommand -OneOrNone $uniquePath
# Full path, now it works!
```