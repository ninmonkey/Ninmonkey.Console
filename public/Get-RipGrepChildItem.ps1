function Get-RipGrepChildItem {
    Write-Warning 'Get-RipGrepChildItem: Wip'
    # rg 'prompt' -c  | ForEach-Object { $_ -replace '\:\d+$', '' } | Tee-Object -Variable 'filelist'

}

& {

    if ($true) {
        return
    }
    Push-Location ( Get-Item 'C:\Users\cppmo_000\Documents\2020\powershell' )

    $testResult = rg 'prompt' -c
    h1 'rip results'
    label 'pwd' $pwd

    $testResult
    h1 'get-item: results'

    Pop-Location
    Write-Warning 'Get-RipGrepChildItem: Wip'
}
