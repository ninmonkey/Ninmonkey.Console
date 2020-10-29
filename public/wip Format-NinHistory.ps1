function Format-NinHistory {
    Write-Warning "WIP: arg filters history then reformats to multi-line CommandLines"
    # func: Pretty History (filtered) for console
    Get-History | Where-Object CommandLine -Match '\$Paths.*=.*' | ForEach-Object {
        (
            #"`n> ", $_.CommandLine -replace '\|', "`n  | "
            "`n>",
            (
                $_.CommandLine -replace '\|', "`n  | "
            )
        ) -join ''
    } | pygmentize.exe -l ps1
}