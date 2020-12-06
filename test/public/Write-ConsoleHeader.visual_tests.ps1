$OutputWithAnsi = & {

    h1 'section1' -fg green
    h1 '34'
    h1 'Piping' -fg green
    0..3 | h1 -LinesBefore 0 -LinesAfter 0
    ''
    0..3 | ForEach-Object {
        "Depth: $_" | h1 -LinesBefore 0 -LinesAfter 0 -Depth $_
    }
    0..3 | ForEach-Object {
        "Depth: $_ -NoPadding" | h1 -LinesBefore 0 -LinesAfter 0 -Depth $_ -NoPadding -fg blue
    }
}
<# output: (with color)

# section1

# 34

# Piping
# 0
# 1
# 2
# 3

Depth: 0
# Depth: 1
## Depth: 2
### Depth: 3
Depth: 0 -NoPadding
Depth: 1 -NoPadding
Depth: 2 -NoPadding
Depth: 3 -NoPadding

#>