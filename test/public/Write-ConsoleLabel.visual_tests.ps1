Import-Module Ninmonkey.Console -Force

Write-ConsoleText 'hi' -fg green -Debug
# | Out-Null
& {
    # Import-Module Ninmonkey.Console -Force | Out-Null
    $VisualConfig = @{
        ArrayVerbose = $true
    }

    if ($VisualConfig.ArrayVerbose) {
        Label 'name' 'fred'
        Label 'species' 'cat' -fg 'green'
        # }
        'cat' | Write-NinLabel 'bob' -fg 'pink' # -Debug

        0, 5, 6 | Label 'num' # -Debug

        0, 5 | Label 'Number: ' # -Debug

        5..7 | ForEach-Object { Label Num $_ -fore magenta }

        Label 'Header with no text' -fore red

        Label 'Join After Pipe' | Out-Host
        'a'..'z' | Label 'Letter: ' -fore red | Join-String -sep ''
        Label 'Join Before Pipe'
        'a'..'z' | Join-String -sep '' | Label 'Letter: ' -fore green
    }


    Get-ChildItem -File . | Sort-Object Name
    | Select-Object -First 5
    | ForEach-Object Name | Label 'File: '
    hr
}

& {
    Label -fg pink 'Change color based on filetype' -before 1 -LinesAfter 1

    Get-ChildItem -Path 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console' | ForEach-Object {
        $cur = $_
        $Color = $null
        $Color = 'lightblue'
        $Suffix = ''
        Test-IsDirectory $cur | Write-Debug
        $cur.name -match '\.md' | Write-Debug
        switch -Regex ($cur) {
            { $true -eq (Test-IsDirectory $_) } {
                $Color = 'Yellow'
                $Suffix = '/'
                break
            }
            { $_.Name -match '\.md' } {
                $Color = 'Blue'
                break
            }
            default {
                break
            }
        }
        $Name = $cur.Name, $Suffix -join ''
        Label $Name -fg $Color
    }
}

& {
    $filesFormatted = Get-ChildItem . | Select-Object -First 3
    | ForEach-Object {
        Label $_.Name (' ', $_.LastWriteTime -join '')
    }
    Label 'As Lines' -fg pink -bef 1
    $filesFormatted

    Label 'As Join-String' -fg pink -bef 1
    $filesFormatted | Join-String -sep ', '
}
