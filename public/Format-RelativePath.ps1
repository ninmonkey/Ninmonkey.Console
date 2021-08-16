
function Format-RelativePath {
    <#
    .synopsis
        convert full path names to relative paths, optionally relative any path.
    .example
        # sample files for below
        PS> ls ~\.vscode | select -First 2 | % FullName
        C:\Users\cppmo_000\.vscode\extensions
        C:\Users\cppmo_000\.vscode\argv.json
    .example
        # use a specific base path
        PS> ls ~\.vscode | select -First 2 | Format-RelativePath ~\.vscode\
        .\extensions
        .\argv.json
    .example
        # use relative your CWD
        PS> PWD
        C:\Users\cppmo_000\Documents\2020\powershell

        PS> ls ~\.vscode | select -First 2 | Format-RelativePath
        ..\..\..\.vscode\extensions
        ..\..\..\.vscode\argv.json
    #>
    param (
        # Filepath
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        # relative path to resolve from
        [Parameter(Position = 0)]
        [string]$BasePath = '.'

    )
    begin {
        Push-Location -StackName 'temp' $BasePath
    }
    process {
        $result = $InputObject | Resolve-Path -Relative

        $debugMeta = [ordered]@{
            rawList  = $InputObject | Join-String -sep ', ' -OutputPrefix '{ ' -OutputSuffix ' }'
            rawCount = $InputObject.Count
            result   = $result
        }
        $result

        $debugMeta | Format-HashTable -Title 'Format-RelativePath()' | Write-Debug
    }
    end {
        Pop-Location -StackName 'temp'
        write-warning 'Already wrote the code using the dotnet method, its far faster'
    }
}

if ($false -and $DebugTestMode) {
    # refactor to use Pester temp drives
    Push-Location -StackName 'debugStack' 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\public'

    $d = Get-Item .
    Format-RelativePath $d -Debug


    $f1 = Get-Item "$PSScriptRoot\data\unicode_web_query.ps1"
    $strList = @(
        '.\native_wrapper\Invoke-IPython.ps1'
        '.\native_wrapper\'
    )

    $strList | Format-RelativePath

    Pop-Location -StackName 'debugStack'
}
