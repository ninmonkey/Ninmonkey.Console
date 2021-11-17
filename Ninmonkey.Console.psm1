﻿using namespace System.Collections.Generic
# using namespace System.Management.Automation
<# init
    todo: better config system, than copying my profile
#>
$PSDefaultParameterValues['Select-NinProperty:Out-Variable'] = 'SelProp'
$PSDefaultParameterValues['Write-ConsoleLabel:fg'] = '7FB2C1'
# $PSDefaultParameterValues['Write-Text:AsString'] = $true
try {
    Set-PSReadLineKeyHandler -Key 'f5' -Function ShowCommandHelp -ea Stop #SilentlyContinue
}
catch {
    # catch [System.Management.Automation.ParameterBindingValidationException] {
    if ($_.ToString() -match 'Cannot validate argument on parameter ''Function''. The argument "ShowCommandHelp"') {
        "Module PSReadline: version {0} is missing function: 'ShowCommandHelp'" -f @( (Get-Module PSReadLine).Version )
        | Write-Warning
    }
    else {
        throw $_
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
}

if ($False) {
    try {
        $FileName = ('{0}\public_autoloader\__init__.ps1' -f $psscriptroot)
        if (Test-Path $FileName ) {
            . $FileName
        }
    }
    catch {
        Write-Error "public_autoloader error: '$fileName'"

    }
}
if ($true) {
    # $base = $psscriptroot ?? ('C:\Users\cppmo_000\Documents\2021\Powershell\My_Github\Ninmonkey.Console')
    # . (Get-Item -ea Stop (Join-Path $base 'public_autoloader\__init__.ps1'))
    . (Get-Item -ea Stop (Join-Path $PSScriptRoot 'public_autoloader\__init__.ps1'))
}


$psreadline_extensions = @(
    'smart_brackets_braces'     # auto add/close quotes and braces
    'ParenthesizeSelection'     # type alt+( to surround existing expression in parenthesis
    # 'ToggleQuoteArgument'       # cycles between qoute types, and none.
    'ExpandAliases'             # expands aliases.
    'IndentSelections_Jaykul'   # indent/dedent selected text:  alt+[ or ]
)


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
    # Write-Warning "file: seeminglySci -> : $File"
    if (Test-Path ('{0}\private\seeminglySci\{1}.ps1' -f $psscriptroot, $file)) {
    }
    else {
        Write-Error "Import: failed: private_seeminglySci: private: $File"
    }
    . ('{0}\private\seeminglySci\{1}.ps1' -f $psscriptroot, $file)
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
    'Invoke-IPython'
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
    'Format-RelativePath'
    'Format-Hashtable'
    'Format-ControlChar'

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
    'Test-IsDirectory'
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

$functionsToExport = @(
    # misc
    'Get-NinMyVSCode'

    'Join-Regex'
    'Resolve-CommandName'
    'Test-UserIsAdmin'
    'Get-NinModule'
    'Import-NinModule'
    'Import-NinPSReadLineKeyHandler'
    'ConvertTo-Timespan'
    'Select-NinProperty'

    # console formatting
    'Write-ConsoleText'
    'Invoke-Wget'
    'Write-ConsoleLabel'
    'Write-ConsoleHeader'
    'Write-ConsoleNewline'
    'Format-RelativePath'
    'Find-GitRepo'
    'Write-ConsoleHorizontalRule'

    # unicode + encoding
    'Get-TextEncoding'
    'Get-UnicodeInfo'
    'Compare-Directory'
    'Get-NinCommandProxy'

    # converters
    'ConvertTo-Number'
    'ConvertTo-HexString'
    'ConvertTo-Base64String'

    'ConvertTo-PropertyList'


    # the rest
    'Get-NativeCommand'
    'Invoke-NativeCommand'
    'Format-TypeName'
    'Format-GenericTypeName'
    'Format-Hashtable'
    'Edit-GitConfig'
    'Export-PlatformFolderPath'

    # history



    # inspection
    'Get-StaticProperty'

    'Get-NinAlias'
    # 'Get-NinNewestItem'
    'Format-Predent'

    'Sort-Hashtable'
    'Invoke-Explorer'
    'Get-NinAppxPackage'
    'ConvertTo-PropertyList'
    'Format-NullText'
    'Test-NullArg'
    'Get-ObjectProperty'
    'Get-ObjectType'
    'Format-FileSize'
    'Format-ControlChar'
    'Trace-NinCommand'

    'Test-IsDirectory'
    'Set-NinLocation'
    'Get-NinCommandSyntax'
    'Get-NinTypeData'
    # 'Get-NinFormatData'
    'Format-History'
    'Get-TerminalName'
    'Write-AnsiHyperlink'
    'Get-NinChildItem'
    'Format-MeasureCommand'
    'Format-TestConnection'
    'Get-ConsoleEncoding'
    'Get-Docs'
    'Get-EnumInfo'
    # 'Get-EnumInfo'

    'Invoke-IPython'
    'Invoke-RipGrepChildItem'
    'Set-ConsoleEncoding'
    'Start-LogTestNet'
    'Test-Net'
    # seemingly-sci
    # 'Get-ElementName'

    'ConvertTo-Number'
    'ConvertTo-HexString'
    'ConvertTo-Base64String'

    'Out-Fzf'
    'Format-PrettyJson'
    # Pester: to remove from Public scope; should be private or only loaded by pester
    'Test-PesterLinesAreEqual'
    'Format-HashTableList'

)
Export-ModuleMember -Function $functionsToExport

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
    # toggle auto importing of aliases', otherwise only use new-alias
    New-Alias -ea 'Ignore' 'Docs' -Value 'Get-Docs' -Description 'Jump to docs by language'
    New-Alias -ea 'Ignore' 'IPython' -Value 'Invoke-IPython' -Description 'ipython.exe defaults using my profile'

    # this wasn't loading below, maybe because old system
    New-Alias 'Select->Property' -Value Select-NinProperty



    # now set as an alias: New-Alias -ea 'Ignore' 'Goto' -Value Set-NinLocation -Description 'a more flexible version of Set-Location / cd'
    New-Alias -ea 'Ignore' 'Here' -Value Invoke-Explorer -Description 'Open paths in explorer'

    # Set-Alias 'Cd' -Value 'Set-NinLocation' -ea Continue #todo:  make this opt in

    # class-explorer
    New-Alias -ea 'Ignore' 'Fm' -Value 'Find-Member' -Description 'uses ClassExplorer'
    New-Alias -ea 'Ignore' -Name 'Get-EnumInfo' -Value 'Get-EnumInfo'

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


        'Select->Property' # Select-NinProperty

        'HelpHistory' # Find-HelpFromHistory

        # console formatting
        'Format-Indent'
        'Label'
        'Br'
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

$FileName = ('{0}\public\completer\{1}' -f $psscriptroot, 'Completer-Loader.ps1')
. $FileName

if ( ($__ninConfig)?.HackSkipLoadCompleters ) {
    Write-Warning '[w] root ⟹ Completer-Loader: Skipped'
}
else {

    $curSplat = @{
        # Verbose = -Verbose
        # Debug   = -Debug
        # infa    = 'Continue'
        # ea      = 'Continue'
    }

    Build-CustomCompleter @curSplat
    Import-CustomCompleter @curSplat
    Import-GeneratedCompleter @curSplat
}
