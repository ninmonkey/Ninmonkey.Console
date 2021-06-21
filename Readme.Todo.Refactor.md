
# Aliases

| alias            | Description                   |
| ---------------- | ----------------------------- |
| - [ ] h1, .., h6 | `Label` with padding          |
| - [ ] Pair       | `Label -sep ': ' $Key $value` |

## JoinStr

- [ ] `joinStrUl` # list item
- [ ] `joinStrLine -sep '\n' `
- [ ] `joinStrCsv`
  -  `-sep ', ' -op '\n'`

# Minimum
## `Write-NinConsoleColor`

Minimal, other commands all use this

- [ ] `wcolor -fg <color> -bg <color> -Text <text>`

```ps1
[h1 | h2] $Text

# call signatures
Label 'Key' -sep ' '
Label 'key' 'value'
```
## `Label`

```ps1
Pipe | Label 'Key' # invokes multiple key value pairs
Pipe | JoinCsv | Label 'stuff'
Label 'key' 'value'

```