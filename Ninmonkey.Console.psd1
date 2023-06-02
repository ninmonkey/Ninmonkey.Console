﻿@{

    # Script module or binary module file associated with this manifest.
    RootModule        = 'Ninmonkey.Console.psm1'

    # Version number of this module.
    ModuleVersion     = '0.2.49'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = '7f1684bf-e55d-4358-9eeb-841c3255020f'

    # Author of this module
    Author            = 'Jake Bolton'

    # Company or vendor of this module
    CompanyName       = 'Jake Bolton'

    # Copyright statement for this module
    Copyright         = '(c) Jake Bolton 2021-2023'

    # Description of the functionality provided by this module
    Description       = 'Utilities making the Command Line more fun'

    # Minimum version of the PowerShell engine required by this module
    # PowerShellVersion = ''

    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # ClrVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules   = @(
        'Pansies'
        'ClassExplorer'
        # 'Utility'           # hard dependency for now
        # 'functional'
    )

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    # regular 'Import-Module name -Force' will re-load these format files
    FormatsToProcess  = @(
        "$PSScriptRoot\public\FormatData\Nin.PropertyList.Format.ps1xml"
    )

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    # FunctionsToExport = '*'
    FunctionsToExport = @(
        # todo: build script automatically include exported commands
        # not wildcard. otherwise wildcard is required if any are defined
        'Edit-FunctionSource' # 'EditFunc'
        'Format-RemoveAnsiEscape' # 'StripAnsi'
        'mergeHashtable'
        'Set-NinLocation' # 'Goto'

        'nin.PSModulePath.Add'
        'nin.PSModulePath.AddNamedGroup'
        'nin.PSModulePath.Clean'

        'Write-ConsoleLabel' # 'Label' # this doesn't auto import my module. maybe a binary lookup ignore already known aliases
        'Format-NativeCommandArguments' # '
        'Invoke-Explorer' # 'Here'
        'Format-UnorderedList' # 'Join.UL'
        'Write-ConsoleHorizontalRule' # 'Hr'
        'Sort-Hashtable'
        '*'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    # AliasesToExport   = '*'  #@()
    AliasesToExport   = @(
        'Goto'
        'EditFunc'
        'Label'
        'Hr' # 'Write-ConsoleHorizontalRule'
        'Iot'
        'Iot2'
        'Here' # 'Invoke-Explorer'
        'StripAnsi' # 'Format-RemoveAnsiEscape'
        'Join.UL' # 'Format-UnorderedList'
        '*'


    )

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

            # Prerelease string of this module
            # Prerelease = ''

            # Flag to indicate whether the module requires explicit user acceptance for install/update/save
            # RequireLicenseAcceptance = $false

            # External dependent modules of this module
            # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.


}
