function Compare-Directory {
    <#
    .SYNOPSIS
    Compare Two directories using 'diff'

    .DESCRIPTION
    wrapper for 'diff'

    .PARAMETER Path1
    First Path

    .PARAMETER Path2
    Second Path

    .EXAMPLE
    Compare-Directory 'c:\foo' 'c:\bar\bat'
    #>
    [Alias('DiffDir')]
    param(
        # Path1
        [Parameter(Mandatory, Position = 0)]
        [string]$Path1,
        # Path2
        [Parameter(Mandatory, Position = 1)]
        [string]$Path2,

        # Output original raw text
        [Parameter()][switch]$OutputRaw
    )

    $Base1 = $Path1 | Get-Item -ea Stop
    $Base2 = $Path2 | Get-Item -ea Stop
    $Label1 = $Base1 | Split-Path -Leaf | New-Text -fg 'green'
    $Label2 = $Base2 | Split-Path -Leaf | New-Text -fg 'yellow'

    "Comparing:
        Path: $Path1
        Path: $Path2
    " | Write-Information

    $stdout = Invoke-NativeCommand 'diff' -args @(
        '-q'
        $Base1
        $Base2
    )

    $outColor = $stdout
    $outColor = $outColor -replace [regex]::Escape($path1), $Label1
    $outColor = $outColor -replace [regex]::Escape($path2), $Label2
    $outColor = $outColor -replace 'Only in', (New-Text 'Only In' -fg 'red')
    $outColor = $outColor -replace 'Differ', (New-Text 'Differ' -fg 'red')

    if ($OutputRaw) {
        h1 'Raw' | Write-Information
        $stdout
        return
    }

    $outColor
}
