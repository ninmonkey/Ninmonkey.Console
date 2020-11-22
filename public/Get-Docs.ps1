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

function _get-DocsDotnet {
    <#
    .synopsis
    search docs for dotnet/powershell
    .notes
        reference urls:

        query parameters:
            view = 'netcore-3.1', 'net-5.0', etc...

        by classname:
        by enumname:
            https://docs.microsoft.com/en-us/dotnet/api/system.io.fileinfo
            https://docs.microsoft.com/en-us/dotnet/api/system.io.fileattributes
    #>

    param (
        [Parameter(
            Mandatory, Position = 0,
            HelpMessage = 'TypeInstance or name')]
        # [string]
        $InputObject
    )

    $PSBoundParameters | Format-Table |  Out-String -w 9999 | Write-Debug

    if ($InputObject -is 'String') {
        $TypeInfo = $InputObject -as 'Type'
        if (! $TypeInfo ) {
            Write-Error "Could not convert to typename: '$InputObject'"
            return
        }
    }
    if ($InputObject -is 'type') {
        $TypeInfo = $InputObject
    } else {
        $TypeInfo = $InputObject.GetType()
    }

    $FullName = $TypeInfo.Namespace, $TypeInfo.Name -join '.'
    Label "Goto: $FullName" -fg Yellow

    $metaDebug = @{
        'FullName'              = $TypeInfo.Namespace, $TypeInfo.Name -join '.'
        'NameColor'             = $TypeInfo | Label 'tinfo' -fg orange
        'InputObject.GetType()' = $InputObject | Format-TypeName
        'TypeInfo'              = $TypeInfo
    }

    $metaDebug |  Write-Debug


    # @{
    #     'ParameterSetName'  = $PSCmdlet.ParameterSetName
    #     'PSBoundParameters' = $PSBoundParameters
    # } | Format-Table |  Out-String | Write-Debug




    $InputObject.GetType().Name | Write-Debug
    "InputObject: '$TypeName'" | New-Text -fg 'green' | Write-Debug
    "TypeInfo: '$TypeInfo'" | New-Text -fg 'green' | Write-Debug
}


if ($false -and 'manual test') {
    $type_gcm = Get-Command | Select-Object -First 1
    $type_file = Get-ChildItem . -File | Select-Object -First 1

    h1 ' literal: FileInfo'
    _get-DocsDotnet 'System.IO.FileInfo' -Debug

    h1 'fromObject: FileInfo'
    _get-DocsDotnet $type_file.GetType() -Debug

    h1 'fromObject: gcm'
    _get-DocsDotnet $type_gcm.GetType() -Debug
    # _get-DocsDotnet 'fake.FileInfo' -Debug
    # _get-DocsDotnet 'System.IO.FileInfo' -Debug
}
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
    Write-Warning 'add: should-process before invoke (refactor to the Out-Browser command)'

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
            Write-AnsiHyperlink $UriList.ExcelFormula "Excel_${Breadcrumb}_Formulas_and_functions" -AsMarkdown
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