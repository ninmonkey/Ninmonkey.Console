using namespace System.Collections.Generic

# __countDuplicateLoad -key 'Nimonkey.Console.psm1'
# using namespace System.Management.Automation
<# init
    todo: better config system, than copying my profile
#>

$__origPrompt = $function:prompt
$PSDefaultParameterValues['Select-NinProperty:Out-Variable'] = 'SelProp'
$PSDefaultParameterValues['Write-ConsoleLabel:fg'] = '7FB2C1'
# $PSDefaultParameterValues['Write-Text:AsString'] = $true
$script:__disabled_UntilIUpdateSeeminglySciMerge = $true
. (Get-Item -ea stop (Join-Path $PSScriptRoot 'private/safe_prompt.ps1'))


# disable for now, because shell integration breaks it
& {
    $hasFunc = (Get-PSReadLineKeyHandler -Bound -Unbound | ForEach-Object Function ) -contains 'ShowCommandHelp'
    if ($hasFunc) {
        Set-PSReadLineKeyHandler -Key 'f12' -Function ShowCommandHelp
    }
}


Set-PSReadLineOption -Colors @{
    Comment = '#E58BEB' # " e[38;2;229;139;235m"
}

<#
future:
    - [ ] use package


#>
<#
    section: seeminglyScience Private
#>

# . 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\private\refactor to csharp\EncodingCompletion.ps1'

$__Config = @{
    includeAliasesUnicode = $true
    includePSReadline     = $false
    DisableTabCompleters  = $true
}

. (Get-Item -ea stop (Join-Path $PSScriptRoot 'root_autoloader.ps1'))

# if ($False) {
#     try {
#         $FileName = ('{0}\public_autoloader\__init__.ps1' -f $psscriptroot)
#         if (Test-Path $FileName ) {
#             . $FileName
#         }
#     } catch {
#         Write-Error "public_autoloader error: '$fileName'"

#     }
# }
# if ($true) {
# $base = $psscriptroot ?? ('C:\Users\cppmo_000\Documents\2021\Powershell\My_Github\Ninmonkey.Console')
# . (Get-Item -ea Stop (Join-Path $base 'public_autoloader\__init__.ps1'))
# . (Get-Item -ea Stop (Join-Path $PSScriptRoot 'public_autoloader\__init__.ps1'))
# }
# function prompt {
#     "`n`n>"
# }

# throw 'stop here debug'

$psreadline_extensions = @(
    'smart_brackets_braces'     # auto add/close quotes and braces
    'ParenthesizeSelection'     # type alt+( to surround existing expression in parenthesis
    # 'ToggleQuoteArgument'       # cycles between qoute types, and none.
    'ExpandAliases'             # expands aliases.
    'IndentSelections_Jaykul'   # indent/dedent selected text:  alt+[ or ]
)


if ('InlineAlwaysImportFirst') {
    # $_cmds = Get-Command -m AwsLambdaPSCore
    # nin.Help.Command.OutMarkdown -Debug -verbose -inputobject $_cmds
    function nin.PSModulePath.Clean {
        <#
        .SYNOPSIS
            -1] remove invalid paths
            -2] remove duplicate paths, preserving sort order
            -3] remove any all-whitespace values
            -4] remove obsolete import path from 2021
        .EXAMPLE
            nin.CleanPSModulePath
        .link
            nin.PSModulePath.Clean
        .link
            nin.PSModulePath.Add
        .link
            nin.PSModulePath.AddNamedGroup
        #>
        [CmdletBinding()]
        param(
            # return the new value
            [switch]$PassThru
        )

        Write-Warning "todo: ensure duplicates are removed: $PSCOmmandPath"

        $records = $Env:PSMODulePath -split ([IO.Path]::PathSeparator)
        | Where-Object { $_ } # drop false and empty strings
        | Where-Object { -not [String]::IsNullOrWhiteSpace( $_ ) } # drop blank

        $records | Join-String -op "initial: `n" -FormatString "`n- {0}" | Write-Debug
        # $records | Join-String -op "`n- " -sep "`n- " -DoubleQuote | write-verbose
        # $records | Join-String -op 'Was:' | Write-Debug

        $records = $records
        | Where-Object { $_ -notmatch ([Regex]::Escape('C:\Users\cppmo_000\SkyDrive\Documents\2021')) }

        $records | Join-String -op "initial: `n" -FormatString "`n- {0}" | Write-Debug

        $finalPath = $records | Join-String -sep ([IO.Path]::PathSeparator)

        $finalPath | Join-String -op 'finalPath = ' | Write-Verbose
        if ($PassThru) {
            return $finalPath
        }
    }

    function nin.PSModulePath.Add {
        <#
        .SYNOPSIS
            add paths to PSModulePath, optionally require existing, or distinct
        .EXAMPLE
            PS> nin.CleanPSModulePath
        .link
            nin.PSModulePath.Clean
        .link
            nin.PSModulePath.Add
        .link
            nin.PSModulePath.AddNamedGroup
        #>
        [CmdletBinding()]
        param(
            [ArgumentCompletions('E:\PSModulePath.2023.root')]
            [Parameter(Mandatory, Position = 0)]
            [string[]]$LiteralPath,
            [switch]$RequireExist,

            # prefix rather than add to end?
            [Alias('ToFront')]
            [switch]$AddToFront
            # [string[]]$GroupName
        )

        $Env:PSModulePath -split ([IO.Path]::PathSeparator) | Join-String -op "`n- " -sep "`n- " -DoubleQuote
        | Join-String -op 'start: ' | Write-Debug

        Write-Warning 'todo: ensure duplicates are removed'

        foreach ($curPath in $LiteralPath) {
            $Item = $curPath
            if ($RequireExists) {

                $Item = Get-Item -ea stop $curPath
                if (-not (Test-Path $Item) ) {
                    # does not always trigger as expected?
                    Write-Error "Not Existing: $Item"
                    continue
                }
            }
            $records = $Env:PSModulePath -split ([IO.Path]::PathSeparator)
            if ($records -contains $Item) { continue }

            Join-String -inp $Item -FormatString 'Adding Path: <{0}>' | Write-Verbose

            if ($AddToFront) {
                $Env:PSModulePath = @(
                    $Item
                    $Env:PSModulePath
                ) | Join-String -sep ([IO.Path]::PathSeparator)
            }
            else {
                $Env:PSModulePath = @(
                    $Env:PSModulePath
                    $Item
                ) | Join-String -sep ([IO.Path]::PathSeparator)
            }

            # Join-String -inp $Item 'adding: "{0}" to $PSModulePath'

        }
        $Env:PSModulePath -split ([IO.Path]::PathSeparator) | Join-String -op "`n- " -sep "`n- " -DoubleQuote
        | Join-String -op 'end  : ' | Write-Debug
    }
    function nin.PSModulePath.AddNamedGroup {
        <#
    .synopsis
        either add a group of custom PSModulePaths by GrupName else full name
    .example
        nin.PSModulePath.AddNamedGroup -GroupName AWS, JumpCloud   -verbose -debug4
    .example

    .example
        nin.PSModulePath.Clean
        nin.PSModulePath.AddNamedGroup -GroupName AWS, JumpCloud   -verbose -debug
        nin.PSModulePath.Add -verbose -debug -RequireExist -LiteralPath @(
            'E:\PSModulePath.2023.root\Main'
            'H:\data\2023\pwsh\PsModules\ExcelAnt\Output'
        )
    #>
        [CmdletBinding(DefaultParameterSetName = 'GroupName')]
        param(
            [ArgumentCompletions('AWS', 'Disabled', 'JumpCloud', 'Main')]
            [Parameter(Mandatory, Position = 0, ParameterSetName = 'GroupName')]
            [string[]]$GroupName,

            [Alias('PSPath', 'Path', 'Name')]
            [Parameter(Mandatory, ParameterSetName = 'LiteralPath', ValueFromPipelineByPropertyName)]
            $LiteralPath
        )
        $Env:PSModulePath -split ([IO.Path]::PathSeparator) | Join-String -op "`n- " -sep "`n- " -DoubleQuote
        | Join-String -op 'Was:' | Write-Debug

        switch ( $PSCmdlet.ParameterSetName ) {
            'GroupName' {
                foreach ($item in $GroupName) {
                    $mappedGroupPath = Join-Path 'E:\PSModulePath.2023.root' $Item
                    nin.PSModulePath.Add -LiteralPath $mappedGroupPath -RequireExist -verbose -debug
                }
                continue
            }

            'LiteralPath' {
                nin.PSModulePath.Add -LiteralPath $LiteralPath -RequireExist -verbose -debug
                continue
            }
            default { throw "UnhandledSwitch ParameterSetItem: $Switch" }
        }
    }

}



if ( -not $__disabled_UntilIUpdateSeeminglySciMerge ) {
    $private_seeminglySci = @(
        'seeminglySci_import'
        'NamespaceAwareCompletion'

        # 'Get-EnumInfo'
        # 'EncodingCompletion'
    )
    if ($psEditor) {
        Write-Debug 'loading namespaceAwareCompletions'
        # see: <https://github.com/SeeminglyScience/dotfiles/b lob/a7a9bcf3624efe5be4988922ba2e35e8ff2fcfd8/PowerShell%2Fprofile.ps1#L147>
        #  $private_seeminglySci.Remove('NamespaceAwareCompletion')
        $private_seeminglySci = $private_seeminglySci -ne 'NamespaceAwareCompletion'
    }

    foreach ($file in $private_seeminglySci) {
        try {
            # Write-Warning "file: seeminglySci -> : $File"
            if (Test-Path ('{0}\private\seeminglySci\{1}.ps1' -f $psscriptroot, $file)) {
            }
            else {
                Write-Error "Import: failed: private_seeminglySci: private: $File"
            }
            . ('{0}\private\seeminglySci\{1}.ps1' -f $psscriptroot, $file)
        }
        catch {
            Write-Error -ErrorRecord $_ -Message "Loading '$file' failed!`n$_" -ea stop
        }
    }
}
<#
    section: Private
#>
$private = @(

    'Toast-LogTestNetResult'
    'pester/Test-PesterLinesAreEqual'
)

foreach ($file in $private) {
    if (Test-Path ('{0}\private\{1}.ps1' -f $psscriptroot, $file)) {
    }
    else {
        Write-Error "Import: private: failed: private: $File"
    }
    . ('{0}\private\{1}.ps1' -f $psscriptroot, $file)
}

<#
    section: native apps
#>

$public_NativeWrapper = @(
    # 'Invoke-IPython'
    # 'Invoke-RipGrepChildItem'
)
foreach ($file in $public_NativeWrapper) {
    if (Test-Path ('{0}\public\native_wrapper\{1}.ps1' -f $psscriptroot, $file)) {
    }
    else {
        Write-Error "Import: failed: public\native_wrapper: $File"
    }
    . ('{0}\public\native_wrapper\{1}.ps1' -f $psscriptroot, $file)

}

Export-ModuleMember -Function $public_NativeWrapper

$public_toDotSource = @(
    # misc
    'Get-NinMyVSCode'
    'Join-Regex'
    'Resolve-CommandName'
    'Test-UserIsAdmin'
    'Get-NinModule'
    'Import-NinModule'
    'ConvertTo-Timespan'
    'Invoke-Wget'
    'Edit-GitConfig'
    'Get-NinAlias'
    'Find-GitRepo'
    'Write-ConsoleText'
    'Write-ConsoleHorizontalRule'
    'Import-NinPSReadLineKeyHandler'


    # console formatting
    'Write-ConsoleLabel'
    'Write-ConsoleHeader'
    'Write-ConsoleNewline'

    'Format-Hashtable'
    'Format-ControlChar'
    # 'Format-ControlChar2'

    # unicode + encoding
    'Get-TextEncoding'
    'Get-UnicodeInfo'

    # other core funcs
    'Get-NativeCommand'
    'Invoke-NativeCommand'

    # converters
    'ConvertTo-Number'
    'ConvertTo-HexString'
    'ConvertTo-Base64String'

    'ConvertTo-PropertyList'

    # inspection
    'Get-StaticProperty'


    # misc
    'Select-NinProperty'

    # the rest
    'Compare-Directory'
    'Get-NinCommandProxy'


    'Export-PlatformFolderPath'
    # history



    'Format-History'
    'Format-MeasureCommand'
    'Format-TestConnection'
    'Get-ConsoleEncoding'
    'Get-Docs'

    'Write-AnsiHyperlink'

    'Trace-NinCommand'
    'Format-Predent'
    'Sort-Hashtable'
    'Get-NinTypeData'
    # 'Get-NinFormatData'
    'Set-NinLocation'
    'Set-ConsoleEncoding'
    'Start-LogTestNet'
    'Test-Net'
    'Get-EnumInfo'
    'Format-FileSize'
    'Format-NullText'
    # 'ConvertTo-PropertyList'

    'Get-NinCommandSyntax'
    'Format-TypeName'
    'Format-GenericTypeName'
    'Get-ObjectProperty'
    'Test-NullArg'
    'Get-NinChildItem'
    'Get-ObjectType'
    'Get-NinAppxPackage'
    'Invoke-Explorer'
    'Get-TerminalName'
    'Format-PrettyJson'
    'Format-HashTableList'
    # 'Get-NinNewestItem'
    'Out-Fzf'

)

<#
    section: public
#>
foreach ($file in $public_toDotSource) {
    if (Test-Path ('{0}\public\{1}.ps1' -f $psscriptroot, $file)) {
        # good
    }
    else {
        Write-Error "Import: failed: public: $File"
    }
    . ('{0}\public\{1}.ps1' -f $psscriptroot, $file)
}

if ($public_toDotSource.count -ge 1 ) {
    Write-Warning 'Imports not fully merged into autoloader: $public_ToDotSource '
}

$functionsToExport = @(


    'nin.PSModulePath.Add'
    'nin.PSModulePath.AddNamedGroup'
    'nin.PSModulePath.Clean'

    # misc
    'ConvertTo-Timespan'
    'Get-NinModule'
    'Get-NinMyVSCode'
    'Import-NinModule'
    'Import-NinPSReadLineKeyHandler'
    'Join-Regex'
    'Resolve-CommandName'
    'Select-NinProperty'
    'Test-UserIsAdmin'

    # console formatting
    'Find-GitRepo'
    'Invoke-Wget'
    'Write-ConsoleHeader'
    'Write-ConsoleHorizontalRule'
    'Write-ConsoleLabel'
    'Write-ConsoleNewline'
    'Write-ConsoleText'

    # unicode + encoding
    'Compare-Directory'
    'Get-NinCommandProxy'
    'Get-TextEncoding'
    'Get-UnicodeInfo'

    # converters
    'ConvertTo-Base64String'
    'ConvertTo-HexString'
    'ConvertTo-Number'
    'ConvertTo-PropertyList'


    # the rest
    'Edit-GitConfig'
    'Export-PlatformFolderPath'
    'Format-GenericTypeName'
    'Format-Hashtable'
    'Format-TypeName'
    'Get-NativeCommand'
    'Invoke-NativeCommand'

    # history



    # inspection
    'Get-StaticProperty'

    'Get-NinAlias'
    # 'Get-NinNewestItem'
    'Format-Predent'

    'ConvertTo-PropertyList'
    'Format-ControlChar'
    'Format-FileSize'
    'Format-NullText'
    'Get-NinAppxPackage'
    'Get-ObjectProperty'
    'Get-ObjectType'
    'Invoke-Explorer'
    'Sort-Hashtable'
    'Test-NullArg'
    'Trace-NinCommand'


    'Format-History'
    'Format-MeasureCommand'
    'Format-TestConnection'
    'Get-ConsoleEncoding'
    'Get-Docs'
    'Get-EnumInfo'
    # 'Get-EnumInfo'
    'Get-NinChildItem'
    'Get-NinCommandSyntax'
    # 'Get-NinFormatData'
    'Get-NinTypeData'
    'Get-TerminalName'
    'Set-NinLocation'
    'Write-AnsiHyperlink'

    'Invoke-IPython'
    'Invoke-RipGrepChildItem'
    'Set-ConsoleEncoding'
    'Start-LogTestNet'
    'Test-Net'
    # 'Get-ElementName'
    # seemingly-sci

    'ConvertTo-Base64String'
    'ConvertTo-HexString'
    'ConvertTo-Number'

    'Format-HashTableList'
    'Format-PrettyJson'
    'Out-Fzf'
    'Test-PesterLinesAreEqual'
    # Pester: to remove from Public scope; should be private or only loaded by pester

)
Export-ModuleMember -Function $functionsToExport

if ($functionsToExport.count -ge 1 ) {
    Write-Warning 'Imports not fully merged into autoloader: $functionsToExport '
}


<#
    section: FormatData
#>
$formatData = @(
    # 'System.RuntimeType'
    # 'Microsoft.PowerShell.Commands.TestConnectionCommand'
    # 'Nin.PropertyList'
)
<#
see also:
    Trace-Command -Name FormatViewBinding, FormatFileLoading {
        #    Update-FormatData -AppendPath 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\public\FormatData\Nin.PropertyList.Format.ps1xml'
        get-date | prop | ft
    } -Verbose -PSHost
#>

function Enable-NinCoreAlias {
    <#
    .synopsis
        loads the "core" / main set of aliases. Call this in your profile.
    .example
        PS> Import-Module Ninmonkey.Console;  Enable-NinCoreAlias
    .notes
        future: Move more 'aliasesToExport' aliases below, to either here, or Ninmonkey.Profile
    #>
    $splat = @{
        ErrorAction = 'ignore'
        Force       = $true
        PassThru    = $true
        Scope       = 'script'
    }

    $aliases = @(
        # group: builtins
        Set-Alias @splat -Name 'io' -Value 'ninmonkey.console\Inspect-ObjectProperty'
        Set-Alias @splat -Name 'ls' -Value 'Microsoft.PowerShell.Management\Get-ChildItem'
        Set-Alias @splat -Name 'impo' -Value 'Microsoft.PowerShell.Core\Import-Module'
        Set-Alias @splat -Name 'jStr' -Value 'Microsoft.PowerShell.Utility\Join-String'
        Set-Alias @splat -Name 'Sc' -Value 'Microsoft.PowerShell.Management\Set-Content'
        Set-Alias @splat -Name 'Gcl' -Value 'Microsoft.PowerShell.Management\Get-Clipboard'
        Set-Alias @splat -Name 'Cl' -Value 'Microsoft.PowerShell.Management\Set-Clipboard'
        Set-Alias @splat -Name 'Touch' -Value 'Microsoft.PowerShell.Management\New-Item'

        Set-Alias @splat -Name 'to->Json' -Value 'Microsoft.PowerShell.Utility\ConvertTo-Json'
        Set-Alias @splat -Name 'to->Csv' -Value 'Microsoft.PowerShell.Utility\ConvertTo-Csv'
        Set-Alias @splat -Name 'from->Json' -Value 'Microsoft.PowerShell.Utility\ConvertFrom-Json'
        Set-Alias @splat -Name 'from->Csv' -Value 'Microsoft.PowerShell.Utility\ConvertFrom-Csv'

        # Set-Alias @splat -Name 'rolve->Cmd' -Value 'Ninmonkey.Console\Resolve-CommandName'

        # group: external modules
        Set-Alias @splat -Name 'Fm' -Value 'ClassExplorer\Find-Member'
        Set-Alias @splat -Name 'fime' -Value 'ClassExplorer\Find-Member'

        # internal funcs
        Set-Alias @splat -Name 'Label' -Value 'Ninmonkey.Console\Write-ConsoleLabel'

        if ($False) {
            'missing, NYI merged into here '
            Set-Alias @splat -Name 'Str' -Value 'Join-StringStyle'
        }
    )
    # | _sortBy_Get-Alias
    $Aliases | Write-Information
    Write-Warning 'remember to import: "_sortBy_Get-Alias"'
    Export-ModuleMember -Alias $aliases
}

$executionContext.SessionState.Module.OnRemove = {

    New-BurntToastNotification -Text 'Module:NinConsole', 'onRemoveEvent fired' -Silent
    Get-Command ls -All | Format-Table | Out-String | Write-Warning
    Write-Warning 'alias "ls" isn''t reverting correctly, until next import'
    Remove-Alias 'ls'# -ea ignore

    # warning still not automatic
    Set-Alias 'ls' 'Microsoft.PowerShell.Management\GetChildItem' -Scope Global
    Get-Command ls -All | Format-Table | Out-String | Write-Warning

}

Export-ModuleMember -Function 'Enable-NinCoreAlias'

<#
Several bugs occur if 'Enable-NinCoreAlias' isn't ran, because
    [1] they are not marked as aliases, so they are not unloaded
        they end up pointing to 'ls.exe', not 'gci'
        when either Module is unloaded, or, Module is imported again
    [2] or makes ninmonkey.profile have errors for not fully loading aliases first

    could fix using
        [1] always load aliases, or
        [2] cleanup on module uevent, or
        [3] minimal module that contains the aliases, removing the dynamic requirement
#>
Enable-NinCoreAlias

foreach ($typeName in $formatData) {

    $FileName = ('{0}\public\FormatData\{1}.Format.ps1xml' -f $psscriptroot, $typeName)
    Get-Item $FileName -ea Continue
    if (Test-Path $FileName ) {
        Update-FormatData -PrependPath $FileName
        Write-Verbose "Imported: FormatData: [$TypeName] $FileName"
    }
    else {
        Write-Error "Import: failed: FormatData: [$TypeName]  $FileName"
    }
}

if ($true) {
    $eaIgnore = @{ ErrorAction = 'Ignore' }
    # toggle auto importing of aliases', otherwise only use new-alias
    New-Alias @eaIgnore 'Docs' -Value 'Get-Docs' -Description 'Jump to docs by language'
    New-Alias @eaIgnore 'IPython' -Value 'Invoke-IPython' -Description 'ipython.exe defaults using my profile'

    # this wasn't loading below, maybe because old system
    New-Alias @eaIgnore 'Select->Property' -Value Select-NinProperty



    # now set as an alias: New-Alias @eaIgnore 'Goto' -Value Set-NinLocation -Description 'a more flexible version of Set-Location / cd'
    New-Alias @eaIgnore 'Here' -Value Invoke-Explorer -Description 'Open paths in explorer'

    # Set-Alias 'Cd' -Value 'Set-NinLocation' -ea Continue #todo:  make this opt in

    # class-explorer
    New-Alias @eaIgnore 'Fm' -Value 'ClassExplorer\Find-Member' -Description 'uses ClassExplorer'
    New-Alias @eaIgnore 'Fime' -Value 'ClassExplorer\Find-Member' -Description 'uses ClassExplorer'
    New-Alias @eaIgnore -Name 'Get-EnumInfo' -Value 'Get-EnumInfo'

    $aliasesToExport = @(
        'H1'
        'Hr'
        'EnumInfo'  # Get-EnumInfo
        'Goto'
        'nLs'       # Get-NinChildItem
        'LsGit'     # Find-GitRepo
        # 'Cd'
        'Docs'
        'Here'
        'IPython'

        'Resolve->Cmd'

        'Select->Property' # Select-NinProperty

        'HelpHistory' # Find-HelpFromHistory

        # console formatting
        'Format-Indent'
        'Label'
        'Br'
        'Import-NinKeys' # Import-NinPSReadLineKeyHandler

        # misc
        'DiffDir'
        'RelativeTs' # ConvertTo-Timespan

        # history

        # which alias for 'Write-ConsoleText'?
        # 'Text' # warning: pansi uses alias 'text'
        'Write-Text'
        'PrettyJson'

        'Prop'
        'Fm'
        'TypeOf'

        ## seemingly sci
        'Default'
        'Convert'

        # 'NameOf'
        'Base64'
        'Hex'
        'Number'
        'Bits'
        'Format-HashTable'

        # inspection
        'StaticMemberProp' # <-- Get-StaticProperty
    )
    Export-ModuleMember -Alias $aliasesToExport
    if ($__Config.includeAliasesUnicode) {
        $aliasesUnicode_ToExport = @(
            'Json🎨'
            # 'Format-HashTable🎨'
        )
        Export-ModuleMember -Alias $aliasesUnicode_ToExport
    }
}

if ( $__Config.DisableTabCompleters) {
    Write-Verbose 'ninConsole => loaders migrating to typewriter' -Verbose
}
else {
    Write-Verbose 'ninConsole => loaders migrating to typewriter' -Verbose
    $FileName = ('{0}\public\completer\{1}' -f $psscriptroot, 'Completer-Loader.ps1')
    . $FileName

    if ( ($__ninConfig)?.HackSkipLoadCompleters ) {
        Write-Warning '[w] root ⟹ Completer-Loader: Skipped'
    }
    else {
        Write-Warning '[w] root ⟹ Completer-Loader: Invoke-Build...'

        $curSplat = @{
            # Verbose = -Verbose
            # Debug   = -Debug
            # infa    = 'Continue'
            # ea      = 'Continue'
        }

        Build-CustomCompleter @curSplat
        Import-CustomCompleter @curSplat
        Import-GeneratedCompleter @curSplat

        # this version works, run it last.
        . (Get-Item (Join-Path $PSScriptRoot '/public/PSReadLine/native-dotnet-completer.ps1'))
    }
}