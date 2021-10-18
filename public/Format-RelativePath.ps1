Export-ModuleMember -Alias 'ConvertTo-RelativePath'
function Format-RelativePath {
    <#
    .synopsis
        convert full path names to relative paths, optionally relative any path.
    .notes
        todo: get the dotnet [io.path] method, which is a lot faster
    .example
        🐒> ls . -Recurse *.json | Format-RelativePath
    .example
          🐒> ls $env:APPDATA *code* -Depth 4
        | select -First 5 | Format-RelativePath -BasePath $env:APPDATA

            Code
            Code - Insiders
            vscode-mssql
    .example
        🐒> ls $env:APPDATA *code* -Depth 4
        | select -First 5 | Format-RelativePath -BasePath $env:UserProfile

            AppData\Roaming\Code
            AppData\Roaming\Code - Insiders
            AppData\Roaming\vscode-mssql
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
    [Alias('ConvertTo-RelativePath')]
    [cmdletbinding()]
    param (
        # Filepath
        [Alias('PSPath', 'Path')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object[]]$InputObject,

        # relative path to resolve from
        [Parameter(Position = 0)]
        [string]$BasePath

    )
    begin {
        # Push-Location -StackName 'temp' $BasePath
        if (! [string]::IsNullOrWhiteSpace( $BasePath) ) {
            $curDir = Get-Item $BasePath
        }
        $curDir ??= Get-Location
    }
    process {
        $InputObject | ForEach-Object {
            $curPath = $_
            [System.IO.Path]::GetRelativePath( $curDir, $curPath )
        }
    }
    end {

    }
}
# write-warning 'Already wrote the code using the dotnet method, its far faster'

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
