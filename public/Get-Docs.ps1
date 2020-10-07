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


https://docs.microsoft.com/en-us/dotnet/standard/base-types/character-encoding-introduction
https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference
https://docs.microsoft.com/en-us/dotnet/standard/base-types/character-classes-in-regular-expressions

urls at:
https://ninmonkeys.com/blog/wp-admin/post.php?post=337&action=edit


' | Write-Debug

# lazy eval so that initial import doesn't take a long time
$_cachedHelpTopics = $null



function Get-Docs {
    <#
    .description
        later will be split into multiple commands
        or user configurable locations
    #>

    param(
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'Main Query'
        )]
        [string]$Query,

        [Parameter(
            Mandatory,
            Position = 0,
            HelpMessage = "which preset to search?")]
        [ValidateSet(
            '.Net',
            '.Net Core',
            '.Net Types',
            'Excel',
            'Power Query',
            # 'About_Powershell',
            'DAX.guide',
            'PowerShell',
            'Ps1',
            'Power BI',
            'VS Code | Docs',
            'VS Code | Dev Docs',
            # 'Github Code Search',
            # 'Github Project',
            # 'Github User',
            # 'Google',
            'Windows Terminal'
        )]
        [string]$Type,

        [parameter(
            HelpMessage = 'Optional regex pattern for some commands'
        )]
        [string]$Pattern
    )

    $QueryIsEmpty = [string]::IsNullOrWhiteSpace( $Query )
    $PatternIsEmpty = [string]::IsNullOrWhiteSpace( $Pattern )
    $Breadcrumb = '➟'
    $UriList = @{
        'ExcelFormula' = 'https://support.microsoft.com/en-us/office/formulas-and-functions-294d9486-b332-48ed-b489-abe7d0f9eda9?ui=en-US&rs=en-US&ad=US#ID0EAABAAA=More_functions'
    }

    if ($null -eq $script:_cachedHelpTopics) {
        $script:_cachedHelpTopics = Get-Help -Name 'about_*' | Select-Object -ExpandProperty Name | Sort-Object
    }

    switch ($Type) {
        'Excel' {
            Write-AnsiHyperlink $UriList.ExcelFormula "Excel_${Breadcrumb}_Formulas_and_functions" -asMarkdown
        }
        'Ps1' {}
        'PowerShell' {

            if ( $Query -like 'about' -or $QueryIsEmpty ) {
                $helpTopics = $_cachedHelpTopics

                if ($PatternIsEmpty) {
                    return $helpTopics
                } else {
                    $helpTopics | Where-Object {
                        $_.Name -match $Pattern
                    }
                    return
                }


            }

            Write-Warning "Nyi: Query '$Type' | ? '$Pattern'"
            break
        }
        # { '.Net' -or

        # }

        # @{
        #     Type  = $Type
        #     Query = $Query
        # } | Format-Table | Out-String | Write-Debug
        default {
            Write-Error "Nyi: '$Type'"
        }
    }
}

# Docs Excel

# Get-Docs 'About_Arrays' PowerShell -Debug -Verbose
# Get-Docs