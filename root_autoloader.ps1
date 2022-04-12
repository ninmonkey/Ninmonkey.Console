#Requires -Version 7.0

using namespace system.collections.generic
# __init__.ps1

# eaiser to manage and filter, especially a dynamic set, in one place
[hashtable]$script:publicToExport = @{
    'function' = @()
    'alias'    = @()
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

class ModuleExportRecord {
    # future:// param that auto-logs when property is changed
    # maybe this is one instance per file
    # which gets appended to global state?
    [List[object]]$function = [List[object]]::new()
    [List[object]]$alias = [List[object]]::new()
    [List[object]]$cmdlet = [List[object]]::new()
    [List[object]]$variable = [List[object]]::new()
    [List[object]]$typeData = [List[object]]::new()   # nyi
    [List[object]]$formatData = [List[object]]::new() # nyi

    # store source filename etc?

    [List[object]]$meta = [List[object]]::new() # nyi
}

$ModuleExportRecord = [ModuleExportRecord]::new()

class NinModuleInfo {
    # global state
    #  PSRealine Exports
    # command line completers
    [ModuleExportRecord[]]$ExportInfo = [list[ModuleExportRecord]]::new()

    [object]$PSReadlineHandlers = @() # or hooks
    [object]$NativeCommand = @()
}

$script:ninModuleInfo = [NinModuleInfo]::new()


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

            $answer = [bool](Test-Any $match_tests)
            'answer: ', $answer -join '' | Write-Information

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

Export-ModuleMember -Function 'Find-AutoloadChildItem'



# $ModuleExportRecord.function.Add( 'Get-DirectChildItem' )

[ModuleExportRecord]@{
    'function' = 'Get-DirectChildItem'
}

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
    $splat = @{
        Recurse = $true
        Force   = $true
        Path    = '.'
        Filter  = '__init__.ps1'
    }
    $dirsToLoad = Get-ChildItem @splat
    | ForEach-Object Directory
    # also test if eq to $PSScriptRoot?
    return $DirsToLoad
}



$dirsToLoad = _find_moduleInitDir
| Sort-Object { $_.FullName -match 'beforeAll' }-Descending  # future will allow sort order from '__init__.ps1'
$dirsToLoad | Write-Host -foreg Green
# |  % fullname

$DirsToLoad | Join-String @strUL | Write-Verbose
$DirsToLoad | Join-String @strUL { $_.Name } | Write-Debug
# | Write-Information
'before'

$NinModuleInfo | ConvertTo-Json -Depth 50 | Set-Content temp:\last_NinModuleInfo.json -Encoding utf8
Get-Content temp:\last_NinModuleInfo.json -Encoding utf8 | bat -l json -f -p | Write-Information


# $origTest = Get-ChildItem -File -Path (Get-Item -ea stop $PSScriptRoot)
$origTest = Get-ChildItem -File -Path $dirsToLoad
| Where-Object { $_.Name -ne '__init__.ps1' }
| Where-Object { $_.Name -ne '__init__.first.ps1' }
| Where-Object { $_.Name -match '\.ps1$' }
| Where-Object { $_.Name -notmatch '\.tests\.ps1$' }

$newTest = Find-AutoloadChildItem -InputPath $dirsToLoad -infa continue

$z = $Null
$z = $Null

return

Write-Warning 'here ->> todo: shared __findImportableChildItems...'
# todo: shared clean and required conditions 2022-03-30
# Don't dot tests, don't call self.
Get-ChildItem -File -Path (Get-Item -ea stop $PSScriptRoot)
| Where-Object { $_.Name -ne '__init__.ps1' }
| Where-Object { $_.Name -ne '__init__.first.ps1' }
| Where-Object { $_.Name -match '\.ps1$' }
| Where-Object { $_.Name -notmatch '\.tests\.ps1$' }
| ForEach-Object {
    $curScript = $_
    . $curScript
}
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
