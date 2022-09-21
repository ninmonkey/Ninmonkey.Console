using namespace System.Collections.Generic
using namespace System.Management.Automation
#Requires -Version 7


if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-WSL-OutString'
        'Find-NativeCommand'

    )
    $publicToExport.alias += @(

    )
    $publicToExport.variable += @(

    )
}


function Find-NativeCommand {
    <#
    .SYNOPSIS
        query for native commands, returns IO.FileInfo of matches
    .EXAMPLE
        Pwsh> Find-NativeCommand 'wsl' | Join-string -sep ', ' Name

            wsl.exe, wslconfig.exe

        Pwsh> Find-NativeCommand 'wsl' -AsLiteral
        | Join-string -sep ', ' Name

            wsl.exe

        Find-NativeCommand py -AsLiteral | Ft name

            Py.exe
    .EXAMPLE
        # throw in cases you require a single, distinct result
        Pwsh> Find-NativeCommand 'python' @{ OneOrNone = $true} -Debug
    .EXAMPLE
        Pwsh> Find-NativeCommand wsl
        Pwsh> Find-NativeCommand python* | select name, length, fullname
    .NOTES
        Note: With Wildcard off, the API will still match 'wsl' to 'wsl.exe'


        get command has at least 5 get-command invokes

        related:
            [IEnumerable[CommandInfo]] GetCommands(
                [string] $name,
                [CommandTypes] $commandTypes,
                [bool] $nameIsPattern)
    .LINK
        https://learn.microsoft.com/en-us/dotnet/api/System.Management.Automation.CommandInvocationIntrinsics?view=powershellsdk-7.0.0#methods
    #>
    [OutputType('[System.IO.FileInfo[]]')]
    [CmdletBinding()]
    param(
        [Alias('Name')]
        [Parameter(mandatory, ValueFromPipeline)]
        [String]$CommandQuery,

        [Alias('WithoutWildcard')]
        [switch]$AsLiteral,

        [ArgumentCompletions(
            '@{ OneOrNone = $true }'
        )]
        [hashtable]$Options = @{}
    )
    begin {
        $Config = Join-Hashtable -OtherHash $Options -BaseHash @{
            OneOrNone = $false
        }
    }
    process {
        if ( -not $AsLiteral ) {
            if ( -not $CommandQuery.EndsWith('*') ) {
                $CommandQuery = $CommandQuery, '*' -join ''
            }
        }
        $commandTypes = [CommandTypes]::Application
        $query = $ExecutionContext.SessionState.InvokeCommand.GetCommands(
            <# name: #> $CommandQuery,
            <# commandTypes: #> $commandTypes,
            <# nameIsPattern: #> (-not $AsLiteral)) | Get-Item

        # $Query | group name | sort Count -Descending | write-verbose

        if($Config.OneOrNone -and $Query.Count -ne 1) {
            $Query | Join-String -sep ', ' FullName -op 'Query: ' -DoubleQuote | Write-debug
            throw "-not OneOrNone: $($Query.count) found"
        }
        return $query
    }

}
function Invoke-WSL-OutString {
    <#
    .synopsis
        Work around returning text when piping returns null (bug? feature?)
    .description
        Work around returning text when piping returns null (bug? feature?)
    .notes
        Suprisingly, this fails to capture anything (when piping)

            Pwsh> wsl --status
                # normal output

            Pwsh> wsl --status | sls 'default'
                # null

            Pwsh> $null -eq (wsl --status | sls 'default')
                # true null


        fix from: <https://discord.com/channels/180528040881815552/447476117629304853/979552419606323260>
        that's the purpose of this wrapper

            $origEncoding = [Console]::OutputEncoding
            [Console]::OutputEncoding = [System.Text.Encoding]::Unicode
            $(try {
                    wsl --status
                } finally {
                    [Console]::OutputEncoding = $origEncoding
                } ) | Select-String 'default'


    .example
        PS>
    #>
    # [RequiresNativeCommand('wsl')] # todo: make this attribute, if nothing else, just make the note on an attribute
    [Alias('cmd-WslOutString')]
    [CmdletBinding()]
    param(

        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$InputCommand
    )
    begin {
        Write-Warning 'not tested'

    }

    process {
        $origEncoding = [Console]::OutputEncoding
        [Console]::OutputEncoding = [System.Text.Encoding]::Unicode
        $(try {
                & wsl @($InputCommand)
            } finally {
                [Console]::OutputEncoding = $origEncoding
            } ) | Select-String 'default'
    }
    end {

    }
}
