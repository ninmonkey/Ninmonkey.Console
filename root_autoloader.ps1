#Requires -Version 7.0
using namespace System.Collections.Generic
# __init__.ps1

Import-Module Pansies -PassThru
# Write-Warning "🐱‍👤finish $PSCommandPath"

$____debug = @{
    Export_Module_Listing_On_Startup = $false
    Export_Super_ExcessiveTest       = $false
}

# eaiser to manage and filter, especially a dynamic set, in one place
[hashtable]$script:publicToExport = @{
    'function' = @(
        'Join-Hashtable'
    )
    'alias'    = @(
        # when random errors occur, so far it's been PSScriptTools\Join-Hashtable causing exceptions
        # 'Join-Hashtable' # to be doubly sure to get priority? else put alias in my module
        # Putting in my profile
    )
    'cmdlet'   = @()
    'variable' = @()
    'meta'     = @()
    # 'formatData' = @()
}

$strUL = @{
    'sep' = "`n  - "
    'op'  = "`n  - "
    'os'  = "`n"
}


'[dev.nin] / refactor this {0}' -f $PSCommandPath | Write-Warning


Function Join-Hashtable {
    <#
    .description
        Copy and append BaseHash with new values from UpdateHash
    .notes
        # WIP
        future: add valuefrom pipeline to $UpdateHash param ?
    .example
        Join-Hashtable -Base @{ a = 1 }
    .link
        Ninmonkey.Console\Join-Hashtable
    .link
        Ninmonkey.Console\Merge-HashtableList
    .link
        Ninmonkey.Powershell\Join-Hashtable
    .link
        PSScriptTools\Join-Hashtable
    #>
    # [Alias('Join-HashTable')]
    [cmdletbinding()]
    [outputType('System.Collections.Hashtable')]
    param(
        # base hashtable
        [Alias('LeftHash')]
        [Parameter(Mandatory, Position = 0)]
        [hashtable]$BaseHash,

        # New values to append and/or overwrite
        [Parameter(Mandatory, Position = 1)]
        [hashtable]$OtherHash,

        # normal is to not modify left, return a new hashtable
        [Alias('UpdateOriginal')]
        [Parameter()][switch]$MutateLeft

        # default Left wins if they share a key name
        # [Parameter()][switch]$PrioritizeRight
    )

    # don't mutate $BaseHash
    process {
        if ($PrioritizeRight) {
            Throw 'Next to implement'
        }

        # $NewHash = [hashtable]::new( $BaseHash )
        if (! $MutateLeft ) {
            $TargetHash = [hashtable]::new( $BaseHash )
        }
        else {
            Write-Debug 'mutating left'
            $TargetHash = $BaseHash
        }

        # sometimes gives
        <#
             Method invocation failed because [System.Collections.Hashtable+KeyCollection] does not contain a method named 'Clone'.
        #>
        # $OtherHash.keys.clone() | ForEach-Object {
        $OtherHash.GetEnumerator() | ForEach-Object {
            $TargetHash[ $_ ] = $OtherHash[ $_ ]
        }
        return $TargetHash
    }
}


function Test-AnyTrueItems {
    <#
    .synopsis
        Test if any of the items in the pipeline are true
    .notes
    # are any of the truthy values?
    .EXAMPLE
        tests:

        $true, $false, $false | Test-AnyTrueItems | Should -be $true
        $null, $null | Test-AnyTrueItems | Should -be $false
        '', '' | Test-AnyTrueItems | Should -be $false
        '', '  ' | Test-AnyTrueItems | Should -be $true
        '', '  ' | Test-AnyTrueItems -BlanksAreFalse | Should -be $true
    #>
    [Alias('Test-AnyTrue', 'nin.AnyTrue')]
    [OutputType('System.boolean')]
    [CmdletBinding()]
    param(
        [Alias('TestBool')]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        # if string, and blank, then treat as false
        [switch]$BlanksAreFalse
    )
    begin {
        $AnyIsTrue = $false
    }
    process {
        foreach ($item in $INputObject) {
            if ($BlanksAreFalse) {
                $test = [string]::isnullorwhitespace($item)
                # or $item -replace '\w+', ''
            }
            else {
                $test = [bool]$item
            }
            #
            if ($Test) {
                $AnyIsTrue = $true
            }
        }
    }

    end {
        return $AnyIsTrue
    }
}


# export-moduleMember -Function 'Test-AnyTrueItems' -alias 'nin.AnyTrue', 'Test.AnyTrue'


class ModuleExportRecord {
    <#
    One Idea is a pre-parse stage:
        [1] ast only, collect any metadata, and registered exports
        [2] potential filter on loaders
        [3] then actually invoke script blocks etc

    allow skipping function, parse without execute
    #>
    # future:// param that auto-logs when property is changed
    # maybe this is one instance per file
    # which gets appended to global state?
    [Collections.Generic.List[object]]$function = @()
    [Collections.Generic.List[object]]$alias = @()
    [Collections.Generic.List[object]]$cmdlet = @()
    [Collections.Generic.List[object]]$variable = @()
    [Collections.Generic.List[object]]$typeData = @()   # nyi
    [Collections.Generic.List[object]]$formatData = @() # nyi

    # store source filename etc?

    [Collections.Generic.List[object]]$meta = @() # nyi
}

# $ModuleExportRecord = [ModuleExportRecord]::new()

class NinModuleInfo {
    # global state
    #  PSRealine Exports
    # command line completers
    [Collections.Generic.List[ModuleExportRecord]]$ExportInfo = [Collections.Generic.List[ModuleExportRecord]]::new()

    [object]$PSReadlineHandlers = @() # or hooks
    [object]$NativeCommand = @()

    [void] AddExportInfo([ModuleExportRecord]$ExportInfo) {
        ## Add argument validation logic here
        # $this.Devices[$slot] = $dev
        $this.ExportInfo.Add( $ExportInfo )
    }
}

[ValidateNotNull()]$script:ninModuleInfo = [NinModuleInfo]::new()


function Find-AutoloadChildItem {
    <#
    .synopsis
        filter out auto runner
    .example
        Find-AutoloadChildItem -path 'public_autoloader'
    #>
    [cmdletbinding()]
    param(
        # root dir to search. maybe allow paths piped
        [Alias('Path', 'PSPath')]
        [parameter(Mandatory)]
        [string[]]$InputPath,

        # names that will be converted to regex-literalsregex literals
        [parameter()]
        [string[]]$ignoreNamesLiteral = @(
            '.visual_tests.ps1',
            '.Interactive.ps1',
            '__init__.ps1',
            # '__init__.first.ps1'
            '.tests.ps1'
        ),
        # [parameter()]
        # [string[]]$ignoreNamesRegex = @()

        [hashtable]$Options = @{}
    )
    begin {
        $Config = @{
            RootFilter = '*.ps1'
            FilterFile = $true
            Recurse    = $false
        }
        # $Config = $Config | Join-Hashtable $Options

        $ignoreNamesLiteral = $ignoreNamesLiteral
        | ForEach-Object { [regex]::Escape($_) }
    }
    process {
        $curPath = $InputPath | Get-Item -ea stop
        $findAutoLoader_Splat = @{
            File    = $Config.FilterFile
            Path    = $curPath
            Filter  = $Config.RootFilter
            Recurse = $Config.Recurse
        }

        $findAutoLoader_Splat | Out-String | Write-Debug

        $filesQuery = Get-ChildItem @findAutoLoader_Splat


        $filteredQuery = $filesQuery
        | Where-Object {
            #future: filter as not directory? -File catches that
            $curFile = $_
            $match_tests = $ignoreNamesLiteral | ForEach-Object {
                $pattern = $_
                Write-Debug "test: '($curFile.Name)' -match '$pattern'"
                $curFile.Name -match $pattern
            }

            # $answer = [bool](Test-Any $match_tests)
            $answer = nin.AnyTrue $match_tests
            # 'answer: ', $answer -join '' | Write-Information
            return -not $answer
        }

        if ($true) {
            # super gross, quick hack, because because Test-Any (where list) didn't seem to be matching correctly
            # prints: 'answer: False' 100% Of the time

            $doubleFilter = $filteredQuery
            | Where-Object { $_.Name -ne '__init__.ps1' }
            | Where-Object { $_.Name -ne '__init__.first.ps1' }
            | Where-Object { $_.Name -match '\.ps1$' }
            | Where-Object { $_.Name -notmatch '\.tests\.ps1$' }

            $filesQuery
            | Join-String @strUl -DoubleQuote
            | Join-String -op '1->filesQuery'
            | Out-String | Write-Debug
            # | Join-String -op 'BeforeFilter = ' -sep ', ' -DoubleQuote
            # | Out-String | Write-Debug

            $filteredQuery
            | Join-String @strUl -DoubleQuote
            | Join-String -op '2->filteredQuery'
            | Out-String | Write-Debug
            # | Join-String -op 'AfterFilter = ' -sep ', ' -DoubleQuote
            # | Out-String | Write-Debug

            $doubleFilter
            | Join-String @strUl -DoubleQuote
            | Join-String -op '3->DoubleFilter'
            | Out-String | Write-Debug
            return $doubleFilter
        }

    }
    end {

    }
}

# Export-ModuleMember -Function 'Find-AutoloadChildItem'
$NinModuleInfo.AddExportInfo(( [ModuleExportRecord]@{
            'function' = 'Join-Hashtable'
        }))


# $ModuleExportRecord.function.Add( 'Get-DirectChildItem' )

# [ModuleExportRecord]@{
#     'function' = 'Get-DirectChildItem'
# }

# $ninModuleInfo

# hardCoded until created
# see: <C:\Users\cppmo_000\Documents\2021\Powershell\My_Github\Dev.Nin\public_experiment\main_import_experimental.ps1>

# try {
# $fileList = @(
#     # 'Get-CommandSummary-OldMethod'
#     'Get-CommandSummafry'
#     'Find-Exception'
# )


# $x = $null
# return
function _find_moduleInitDir {
    <#
    .synopsis
        sugar to find '__init__.ps1' files, returning their parent directories
    .notes
        ask sci: how would I pass and invoke a custom sort order?
            _find_moduleInitDir -path . -Sort { $_.Name  } -Descending
    #>
    param(
        [Parameter()]
        [string]$Path = (Get-Item $PSScriptRoot)
    )
    $splat = @{
        Recurse = $true
        Force   = $true
        Path    = $Path
        Filter  = '__init__.ps1'
    }
    $dirsToLoad = Get-ChildItem @splat
    | ForEach-Object Directory
    # also test if eq to $PSScriptRoot?
    return $DirsToLoad
}



$dirsToLoad = _find_moduleInitDir
| Sort-Object { $_.FullName -match 'beforeAll' } -Descending  # future will allow sort order from '__init__.ps1'

$dirsToLoad | Write-Host -foreg Green
# |  % fullname

$DirsToLoad
| Join-String @strUL | Write-Verbose
$DirsToLoad
| Join-String @strUL { $_.Name } | Write-Debug
# | Write-Information
# 'before'

# $NinModuleInfo
#     | ConvertTo-Json -Depth 50 | Set-Content 'temp:\last_NinModuleInfo.json' -Encoding utf8

# Get-Content 'temp:\last_NinModuleInfo.json' -Encoding utf8
#     | bat -l json -f -p | Write-Information


# $origTest = Get-ChildItem -File -Path (Get-Item -ea stop $PSScriptRoot)
$origTest = Get-ChildItem -File -Path $dirsToLoad
| Where-Object { $_.Name -ne '__init__.ps1' }
| Where-Object { $_.Name -ne '__init__.first.ps1' }
| Where-Object { $_.Name -match '\.ps1$' }
| Where-Object { $_.Name -notmatch '\.tests\.ps1$' }

$newTest = Find-AutoloadChildItem -InputPath $dirsToLoad -infa 'continue'
# | Sort-Object { $_.fullname -match 'zeroDepend_autoloader' } -Descending
| Sort-Object { $_.fullname -match '' } -Descending

class ParseResult {
    [IO.FileSystemInfo]$Name
    [bool]$Success
    [Collections.Generic.List[object]]$Error = [Collections.Generic.List[object]]::new()
}

[Collections.Generic.List[ParseResult]]$parseResultSummary = [Collections.Generic.List[ParseResult]]::new()

$newTest
| ForEach-Object {
    $Cur = $_
    $parseResult = [ParseResult]@{
        Name    = $Cur
        Success = $true
    }
    try {
        . $Cur
    }
    catch {
        $ParseResult.Success = $false
        $ParseResult.Error.AddRange( @($_) )
    }

    $parseResultSummary.Add( $parseResult )
}

# Don't dot tests, don't call self.
# Get-ChildItem -File -Path (Get-Item -ea stop $PSScriptRoot)
# | Where-Object { $_.Name -ne '__init__.ps1' }
# | Where-Object { $_.Name -ne '__init__.first.ps1' }
# | Where-Object { $_.Name -match '\.ps1$' }
# | Where-Object { $_.Name -notmatch '\.tests\.ps1$' }
# | ForEach-Object {
#     # $curScript = $_
#     # . $curScript
# }
# are these safe? or will it alter where-object?
# Write-Debug "[dev.nin] importing experiment '$($_.Name)'"
# } catch {
# Write-Error -Exception $_ -Message "DotsourceImportFailed: public_autoloader\__init__.ps1: '$($curScript)'" -TargetObject $_ -Category InvalidOperation
# Write-Error "todo: correctly throw: '$_'"
# }
# } catch {
# Write-Error "public_autoloader\__init__.ps1:  failed`ntodo: correctly throw: '$_'"
# Write-Error -Exception $_ -Message ''
# }

$script:publicToExport | Join-String -op 'ExperimentToExport' | Write-Debug

if ($ninModuleInfo.ExportInfo.function) {
    Export-ModuleMember -Function $ninModuleInfo.ExportInfo.function
}
if ($ninModuleInfo.ExportInfo.alias) {
    Export-ModuleMember -Alias $ninModuleInfo.ExportInfo.alias
}
if ($ninModuleInfo.ExportInfo.cmdlet) {
    Export-ModuleMember -Cmdlet $ninModuleInfo.ExportInfo.cmdlet
}
if ($ninModuleInfo.ExportInfo.variable) {
    Export-ModuleMember -Variable $ninModuleInfo.ExportInfo.variable
}
if ($ninModuleInfo.ExportInfo.typeData) {
    Write-Warning '$ninModuleInfo.TypeData export is NYI'
}
if ($ninModuleInfo.ExportInfo.formatData) {
    Write-Warning '$ninModuleInfo.FormatData export is NYI'
}

if ($script:publicToExport['function']) {
    Export-ModuleMember -Function $script:publicToExport['function']
}
if ($script:publicToExport['alias']) {
    Export-ModuleMember -Alias $script:publicToExport['alias']
}
if ($script:publicToExport['cmdlet']) {
    Export-ModuleMember -Cmdlet $script:publicToExport['cmdlet']
}
if ($script:publicToExport['variable']) {
    Export-ModuleMember -Variable $script:publicToExport['variable']
}

$meta | Format-Table | Out-String | Write-Information

# if ($true) {
#     # tip: 'Join-String' does not require the empty and $null gaurds, left in for intent
#     # detect not yet transferred over
#     if ($publicToExport.function.Count -gt 0) {
#         $publicToExport.function
#             | Join-String @strUl
#             | Join-String -op "(eventually deprecated warning): `$publicToExport.function is not empty, migrate to 'ninModuleInfo' Items: `n"
#             | Write-Debug
#     }
#     if ($publicToExport.alias.Count -gt 0) {
#         $publicToExport.alias
#             | Join-String @strUl
#             | Join-String -op "(eventually deprecated warning): `$publicToExport.alias is not empty, migrate to 'ninModuleInfo' Items: `n"
#             | Write-Debug

#     }
#     if ($publicToExport.cmdlet.Count -gt 0) {
#         $publicToExport.cmdlet | Join-String @strUl | Write-Warning # | Write-Debug
#         | Join-String -op "(eventually deprecated warning): `$publicToExport.cmdlet is not empty, migrate to 'ninModuleInfo' Items: `n"
#         | Write-Debug
#     }
#     if ($publicToExport.variable.Count -gt 0) {
#         $publicToExport.variable | Join-String @strUl | Write-Warning # | Write-Debug
#         | Join-String -op "(eventually deprecated warning): `$publicToExport.variable is not empty, migrate to 'ninModuleInfo' Items: `n"
#         | Write-Debug
#     }
# }
$devNinRoot = '~\.dev-nin\dump'


$__exportPaths = @{
    DevNinRoot                               = $devNinRoot
    LogExportBase                            = $devvNinRoot #'~\.dev-nin\dump' #'\console-last_import.json'
    Export_moduleExports_FromList            = Join-Path $devNinRoot 'console-last_list_import.json'
    Export_moduleExports_FromClass           = Join-Path $devNinRoot 'console-last_class_import.json'
    Export_moduleExports_FromClass_Expand    = Join-Path $devNinRoot 'console-last_class_import-ExportInfo.json'
    Export_moduleExports_parseResult         = Join-Path $devNinRoot 'console-last_parse_result.json'
    Export_moduleExports_parseResult_summary = Join-Path $devNinRoot 'console-last_parse_result-summary.json'

}

if ($false -and $____debug.Export_Super_ExcessiveTest) {
    "`$____debug.Export_Super_ExcessiveTest: `$true from '$PSCommandPath'"
    | Write-Warning
    # dump json logs
    $publicToExport
    | ConvertTo-Json -Depth 9 -EnumsAsStrings #-EscapeHandling Default
    | Set-Content -Path $__exportPaths['Export_moduleExports_FromList'] -Encoding utf8

    $ninModuleInfo
    | ConvertTo-Json -Depth 9 -EnumsAsStrings #-EscapeHandling Default
    | Set-Content -Path $__exportPaths['Export_moduleExports_FromClass'] -Encoding utf8

    $ninModuleInfo.ExportInfo
    | ConvertTo-Json -Depth 9 -EnumsAsStrings #-EscapeHandling Default
    | Set-Content -Path $__exportPaths['Export_moduleExports_FromClass_Expand'] -Encoding utf8

    $parseResult
    | ConvertTo-Json -Depth 4 -EnumsAsStrings #-EscapeHandling Default
    | Set-Content -Path $__exportPaths['Export_moduleExports_parseResult'] -Encoding utf8

    $parseResult
    | ConvertTo-Json -ea ignore -Depth 4 -EnumsAsStrings #-EscapeHandling Default
    | Set-Content -Path $__exportPaths['Export_moduleExports_parseResult_Summary'] -Encoding utf8

    @(
        $__exportPaths['Export_moduleExports_FromList']
        $__exportPaths['Export_moduleExports_FromClass']
        $__exportPaths['Export_moduleExports_FromClass_Expand']
        $__exportPaths['Export_moduleExports_parseResult']
        $__exportPaths['Export_moduleExports_parseResult_Summary']
    ) | Join-String @strUL
    | Join-String -op "Wrote files`n"
    | Write-Warning

    Write-Warning 'finish formatter, replaces all file info with strings, datetime with string, process as string, etc'
}


if ($false -and $____debug.Export_Module_Listing_On_Startup) {
    "`$____debug.Export_Module_Listing_On_Startup: `$true from '$PSCommandPath'"
    # $destPrefix = $PSScriptRoot
    $destPrefix = Get-Item 'C:\nin_temp\1234'

    Write-Verbose "Exporting Modules to: '${destPrefix}/*' "
    Write-Information "Exporting Modules to: '${destPrefix}/*' "

    $parseResultSummary
    | ConvertTo-Json -Depth 20
    | Set-Content -Path (Join-String $destPrefix 'parseResultSummary.json') -Encoding utf8

    $NinModuleInfo
    | ConvertTo-Json -Depth 20
    | Set-Content -Path (Join-String $destPrefix 'ninModuleInfo.json') -Encoding utf8

    $NinModuleInfo.ExportInfo
    | ConvertTo-Json -Depth 20
    | Set-Content -Path (Join-String $destPrefix 'ninModuleInfo-exportInfo.json') -Encoding utf8
    # todo: shared clean and required conditions 2022-03-30
}

# $fileList | ForEach-Object {
#     $RelativePath = "$_.ps1"
#     $src = Join-Path $PSSCriptRoot $RelativePath
#     if (!(Test-Path $src)) {
#         Write-Error  "Unknown import: '$RelativePath'"
#         return
#     }
#     try {
#         . $src

#     }
# catch {
# One nuance of $PSCmdlet.ThrowTerminatingError() is that it creates a terminating error within your Cmdlet but it turns into a non-terminating error after it leaves your Cmdlet.
# but the pipeline ends regardless of a '-Ea Continue'
# $PSCmdlet.ThrowTerminatingError($PSItem)
# $_.InvocationInfo, and inner exception: <https://powershellexplained.com/2017-04-10-Powershell-exceptions-everything-you-ever-wanted-to-know/#psiteminvocationinfo>
# $PSCmdlet.ThrowTerminatingError($PSItem)
# Write-Error "Import failed '$RelativePath'" -Exception $_
# }
# }
# }
# catch {
# Write-Error -Exception $_ -Message 'autoloader failed'
# return
# throw -e
# throw $_
# }
# Export-ModuleMember -Function $funcList

# . (Join-Path $PSSCriptRoot 'Get-CommandSummary.ps1')
# Export-ModuleMember 'Get-CommandSummary-OldMethod'
