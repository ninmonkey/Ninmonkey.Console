#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'ConvertTo-RelativePath'
    )
    $publicToExport.alias += @(
        'To->RelativePath'
    )
}

function ConvertTo-RelativePath {
    <#
    .synopsis
        relative paths, allows you to pipe to commands that expects raw text like 'fzf preview'.
    .description
        todo: #1 #6

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
        🐒> ls . -Recurse *.json | ConvertTo-RelativePath
    .example
          🐒> ls $env:APPDATA *code* -Depth 4
        | select -First 5 | ConvertTo-RelativePath -BasePath $env:APPDATA

            Code
            Code - Insiders
            vscode-mssql
    .example
        🐒> ls $env:APPDATA *code* -Depth 4
        | select -First 5 | ConvertTo-RelativePath -BasePath $env:UserProfile

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
        🐒> ls -Force ~\.vscode | ConvertTo-RelativePath "$Env:USERPROFILE"

            .vscode\extensions
            .vscode\argv.json
    .example
        # use relative your CWD

        🐒> ls .\My_Gist\ | To->RelativePath

            My_Gist\AngleSharp Example
            My_Gist\Calling-Pwsh-Commands-With-Dynam
            My_Gist\Making regular expressions reada

    .outputs
        [string] , or $null if emptystring/nulls are passed
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
        [AllowEmptyString()]
        [AllowNull()]
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
            '$Env:AppData',
            '$Env:LocalAppData',
            '$Env:Nin_Dotfiles',
            '$Env:Nin_Home',
            '$Env:Nin_PSModulePath',
            '$Env:NinEnableToastDebug',
            '$Env:NinNow',
            '$Env:UserProfile',
            '$Env:UserProfile\SkyDrive\Documents\2021',
            '2021-github-downloads'
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
        $curDir = Get-Location | Get-Item
    }
    process {

        <#
        ripgrep and/or grep have file line numbers  at the start, or end, depending on mode
        #>

        $InputObject | ForEach-Object {
            # if *everything* fails, return initial value
            $rawItem = $_ # maybe always strip ansi ?

            if ($null -eq $rawItem) {
                return
            }

            try {
                # Write-Warning "WIP $PSSCommand"
                if ($rawItem -is 'string') {
                    $parsedItem = $rawItem | Remove-AnsiEscape
                } else {
                    $parsedItem = $rawItem
                }

                # $maybeNameList = @(
                #     $parsedItem
                #     $parsedItem -replace '(:\d+)$', ''
                # )
                try {
                    $curItem = Get-Item $parsedItem -ea stop
                } catch {
                    # Write-Error "Get-Item  failed on: '$parsedItem', falling back to text"
                    Write-Debug "Get-Item failed on: '$parsedItem', falling back to text"
                    $curItem = $parsedItem
                }

                # if (! $LiteralPath) {
                #     $curItem = Get-Item $parsedItem
                # }
                # h1 'end of rel path' | Write-Host
                if ($null -eq $curItem) {
                    Write-Debug 'curItem: $null'
                    return
                }
                if ($null -eq $curDir) {
                    Write-Debug 'curDir: $null'
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
#     ConvertTo-RelativePath $d -Debug


#     $f1 = Get-Item "$PSScriptRoot\data\unicode_web_query.ps1"
#     $strList = @(
#         '.\native_wrapper\Invoke-IPython.ps1'
#         '.\native_wrapper\'
#     )

#     $strList | ConvertTo-RelativePath

#     Pop-Location -StackName 'debugStack'
# }


if (! $publicToExport) {
    # ...
}
