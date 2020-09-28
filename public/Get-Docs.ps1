function Get-Docs {
    <#
    .description
        later will be split into multiple commands
        or user configurable locations
    #>

    param(
        [Parameter(
            Mandatory, Position = 0,
            HelpMessage = 'Main Query'
        )]
        [string]$Query,

        [Parameter(
            Mandatory,
            Position = 1,
            HelpMessage = "which preset to search?"
        )]
        [ValidateSet( 'PowerShell',
            '.Net',
            '.Net Core',
            '.Net Types',
            'Power Query',
            # 'About_Powershell',
            'DAX.guide',
            'PowerShell',
            'Power BI',
            'VS Code | Docs',
            'VS Code | Dev Docs',
            # 'Github Code Search',
            # 'Github Project',
            # 'Github User',
            # 'Google',
            'Windows Terminal'
        )]
        [string]$Name
    )

    @{
        Query = $Query
        Name  = $Name
    } | Format-Table | Out-String | Write-Debug
}

'more
urls for get docs


format strings
	https://docs.microsoft.com/en-us/dotnet/standard/base-types/formatting-types
https://docs.microsoft.com/en-us/dotnet/standard/base-types/formatting-types
https://docs.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings
https://docs.microsoft.com/en-us/dotnet/standard/base-types/custom-date-and-time-format-strings

about_*
	https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_calculated_properties?view=powershell-7

cmdlet
	https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-formatdata?view=powershell-7


'


Get-Docs 'About_Arrays' PowerShell
# Get-Docs