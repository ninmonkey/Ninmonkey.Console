Export-ModuleMember -Alias 'ConvertTo-RelativePath'
function Format-RelativePath {
    <#
    .synopsis
        relative paths, allows you to pipe to commands that expects raw text like 'fzf preview'. 
    .description
        Transforms both paths as text and (get-item)s
            - convert to the raw File.FullName raw text
            - convert to relative path
        If not specified, it uses your current directory

        for files/folders, converts to the string relative path
        this is meant to pre-process items as was as j
        todo: get the dotnet [io.path] method, which is a lot faster
    .example
        newestItem🔎 Code-Workspace💻 | StripAnsi | To->RelativePath | pipe->Peek
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
        🐒> ls -Force ~\.vscode | Format-RelativePath "$Env:USERPROFILE"

            .vscode\extensions
            .vscode\argv.json
    .example
        # use relative your CWD

        🐒> ls .\My_Gist\ | To->RelativePath

            My_Gist\AngleSharp Example
            My_Gist\Calling-Pwsh-Commands-With-Dynam           
            My_Gist\Making regular expressions reada
            
    .outputs
        [string]
    .link
        https://docs.microsoft.com/en-us/dotnet/api/system.io.path.getrelativepath
    .link
        https://docs.microsoft.com/en-us/dotnet/api/system.io.path.getfullpath
    #>
    [Alias('ConvertTo-RelativePath')]
    [cmdletbinding()]
    param (
        # Filepath
        [Alias('PSPath', 'Path', 'To->RelativePath')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object[]]$InputObject,

        # relative path to resolve from
        # future, use completions so visual and final replace are different
        # it can show 'dotfiles' but really use env vars, etc.
        # $items = "$Env:UserProfile", "$Env:AppData", "$Env:LocalAppData"
        # | ForEach-Object tostring
        # , $items
        [Parameter(Position = 0)]
        [ArgumentCompletions(
            'C:\Users\cppmo_000\SkyDrive\Documents\2021',
            'C:\Users\cppmo_000\AppData\Roaming',
            'C:\Users\cppmo_000\AppData\Local',
            'C:\Users\cppmo_000'
        )]
        [string]$BasePath

    )
    begin {
        $Config = @{
            AlwaysStripAnsi = $true
        }
        # Push-Location -StackName 'temp' $BasePath
        if (! [string]::IsNullOrWhiteSpace( $BasePath) ) {
            $curDir = Get-Item $BasePath
        }
        $curDir ??= Get-Location
    }
    process {
        $InputObject | ForEach-Object {
            $curItem = $_
            if ($curItem -is 'string') {
                $curItem = $curItem | Remove-AnsiEscape
            }
            $curItem = Get-Item $curItem
            if ($null -eq $curItem) {
                Write-Error 'curItem: $null'
                return 
            }
            if ($null -eq $curDir) {
                Write-Error 'curDir: $null'
                return 
            }
            
            [System.IO.Path]::GetRelativePath( $curDir, $curItem )
        }
    }
    end { }
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
