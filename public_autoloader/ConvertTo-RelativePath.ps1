#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'ConvertTo-RelativePath'
    )
    $publicToExport.alias += @(
        'To->RelativePatha'
    )
}

function ConvertTo-RelativePath {
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
    [Alias('To->RelativePath')]
    [cmdletbinding()]
    param (
        # Filepath
        [Alias('PSPath', 'Path')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object[]]$InputObject,

        # relative path to resolve from
        # future, use completions so visual and final replace are different
        # it can show 'dotfiles' but really use env vars, etc.
        # $items = "$Env:UserProfile", "$Env:AppData", "$Env:LocalAppData"
        # | ForEach-Object tostring
        # , $items
        # todo: these completions should be short looking alias names
        [Parameter(Position = 0)]
        [ArgumentCompletions(
            'C:\Users\cppmo_000\SkyDrive\Documents\2021',
            'C:\Users\cppmo_000\AppData\Roaming',
            'C:\Users\cppmo_000\AppData\Local',
            'C:\Users\cppmo_000'
        )]
        [string]$BasePath,

        # interpret strings as literal path, verses get-item which resolves to many files
        # paths with globs or 'c:\foo\*' resolve to many paths if this is off
        [alias('LiteralPath')]
        [switch]$AsLiteralPath

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
        <#
        ripgrep and/or grep have file line numbers  at the start, or end, depending on mode
        #>


        $InputObject | ForEach-Object {
            # if *everything* fails, return initial value
            $rawItem = $_ # maybe always strip ansi ?
            try {
                if ($rawItem -is 'string') {
                    $parsedItem = $rawItem | Remove-AnsiEscape
                } else {
                    $parsedItem = $rawItem
                }

                $maybeNameList = @(
                    $parsedItem
                    $parsedItem -replace '(:\d+)$', ''
                )
                try {
                    $curItem = Get-Item $parsedItem -ea stop
                } catch {
                    Write-Error "Get-Item failed on: '$parsedItem', falling back to text"
                    $curItem = $parsedItem
                }

                # if (! $LiteralPath) {
                #     $curItem = Get-Item $parsedItem
                # }
                if ($null -eq $curItem) {
                    Write-Error 'curItem: $null' -ea Stop #SilentlyContinue
                    return
                }
                if ($null -eq $curDir) {
                    Write-Error 'curDir: $null' -ea Stop #SilentlyContinue
                    return
                }

                [System.IO.Path]::GetRelativePath( $curDir, $parsedItem )
            } catch {
                Write-Warning "Conversion failed on '$rawItem'. $_"
                $rawItem
            }
        }
    }
    end {
    }
}

# if ($false -and $DebugTestMode) {
#     # refactor to use Pester temp drives
#     Push-Location -StackName 'debugStack' 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\public'

#     $d = Get-Item .
#     Format-RelativePath $d -Debug


#     $f1 = Get-Item "$PSScriptRoot\data\unicode_web_query.ps1"
#     $strList = @(
#         '.\native_wrapper\Invoke-IPython.ps1'
#         '.\native_wrapper\'
#     )

#     $strList | Format-RelativePath

#     Pop-Location -StackName 'debugStack'
# }


if (! $publicToExport) {
    # ...
}