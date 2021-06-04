<#
    section: seeminglyScience Private
#>

# . 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\private\refactor to csharp\EncodingCompletion.ps1'

$__Config = @{
    includeAliasesUnicode = $true
}

$private_seeminglySci = @(
    'seeminglySci_import'
    'NamespaceAwareCompletion'
    'Get-SciEnumInfo'
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

<#
    section: Completers
#>
$completer = @(
    'Completer-dotnet'
    'Completer-RipGrep'
    'Completer-gh'
)

foreach ($file in $completer) {
    if (Test-Path ('{0}\public\completer\{1}.ps1' -f $psscriptroot, $file)) {
    }
    else {
        Write-Error "Import: failed: completer: $File"
    }
    . ('{0}\public\completer\{1}.ps1' -f $psscriptroot, $file)
}

Export-ModuleMember -Function $completer

$public = @(
    # misc
    'ConvertTo-Timespan'
    'Invoke-Wget'
    'Edit-GitConfig'
    'Get-NinAlias'
    'Find-GitRepo'
    'Write-ConsoleHorizontalRule'

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
    'ConvertTo-BitString'
    'ConvertTo-PropertyList'

    # the rest
    'Compare-Directory'


    'Export-PlatformFolderPath'
    'Format-History'
    'Format-MeasureCommand'
    'Format-TestConnection'
    'Get-ConsoleEncoding'
    'Get-Docs'
    'Test-UserIsAdmin'
    'Write-AnsiHyperlink'
    'Get-NinModule'
    'Trace-NinCommand'
    'Format-Predent'
    'Sort-Hashtable'
    'Get-NinTypeData'
    # 'Get-NinFormatData'
    'Set-NinLocation'
    'Set-ConsoleEncoding'
    'Start-LogTestNet'
    'Test-Net'
    # 'Get-EnumInfo'
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
foreach ($file in $public) {
    if (Test-Path ('{0}\public\{1}.ps1' -f $psscriptroot, $file)) {
    }
    else {
        Write-Error "Import: failed: public: $File"
    }
    . ('{0}\public\{1}.ps1' -f $psscriptroot, $file)
}

$functionsToExport = @(
    # misc
    'ConvertTo-Timespan'

    # console formatting
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

    # converters
    'ConvertTo-Number'
    'ConvertTo-HexString'
    'ConvertTo-Base64String'
    'ConvertTo-BitString'
    'ConvertTo-PropertyList'


    # the rest
    'Get-NativeCommand'
    'Invoke-NativeCommand'
    'Format-TypeName'
    'Format-GenericTypeName'
    'Format-Hashtable'
    'Edit-GitConfig'
    'Export-PlatformFolderPath'


    'Get-NinAlias'
    # 'Get-NinNewestItem'
    'Format-Predent'
    'Test-UserIsAdmin'
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
    'Get-SciEnumInfo'
    # 'Get-EnumInfo'
    'Get-NinModule'
    'Invoke-IPython'
    'Invoke-RipGrepChildItem'
    'Set-ConsoleEncoding'
    'Start-LogTestNet'
    'Test-Net'
    # seemingly-sci
    # 'Get-ElementName'
    'ConvertTo-BitString'
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

    # now set as an alias: New-Alias -ea 'Ignore' 'Goto' -Value Set-NinLocation -Description 'a more flexible version of Set-Location / cd'

    New-Alias -ea 'Ignore' 'Here' -Value Invoke-Explorer -Description 'Open paths in explorer'

    # Set-Alias 'Cd' -Value 'Set-NinLocation' -ea Continue #todo:  make this opt in

    # class-explorer
    New-Alias -ea 'Ignore' 'Fm' -Value 'Find-Member' -Description 'uses ClassExplorer'
    New-Alias -ea 'Ignore' -Name 'Get-EnumInfo' -Value 'Get-SciEnumInfo'

    $aliasesToExport = @(
        'H1'
        'Hr'
        'Get-EnumInfo'
        'Goto'
        'nLs'       # Get-NinChildItem
        'LsGit'     # Find-GitRepo
        # 'Cd'
        'Docs'
        'Here'
        'IPython'

        # console formatting
        'Format-Indent'
        'Label'
        'Br'
        'Br'

        # misc
        'DiffDir'
        'RelativeTs' # ConvertTo-Timespan

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