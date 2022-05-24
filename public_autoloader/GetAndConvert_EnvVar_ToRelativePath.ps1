function relEnv {
    <#
        notes: future:
            add hotkey, so command line can fix it
            'oh', "undo" then appy my fix, after the coerce, because of undo state?

    #>
    # show len


    $Env:USERPROFILE, $Env:LOCALAPPDATA, $Env:APPDATA | Sort-Object -des

    $ninEnv = Get-ChildItem env:
    | Where-Object { $_.Value -Match 'c:' -or (Test-Path $_.Value) }
    | Sort-Object value | ForEach-Object {
        # order by lenght of most-possible-replaced-text
        $accum = $accum -replace (ReLit $Env:LocalAppData), '$Env:LocalAppData'
        | Join-String -op "${bg:gray30}" -os $PSStyle.Reset

        $accum = $accum -replace (ReLit $Env:AppData), '$Env:LocalAppData'
        $accum = $accum -replace (ReLit $Env:UserProfile), '$Env:UserProfile'

        [pscustomobject]@{
            Key   = $_.Key
            Value = $_.Value
            Len   = $_.Value.Length
            Short = $cleanVal
        }
    }
    $ninEnv
    # to update
}

Write-Warning "Import me $PSCommandPath"
# $res = relEnv; $res | Format-Table Key, Short, Value -AutoSize
# $res | Select-Object -Last 3 | Format-List
