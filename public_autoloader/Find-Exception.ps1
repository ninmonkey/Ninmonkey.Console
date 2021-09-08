#Requires -Module 'ClassExplorer'

$script:publicToExport.function += @('Find-Exception')
# $script:publicToExport.alias += @('Find-Exception')

function Find-Exception {
    <#
    .synopsis
        Enumerate found [Exception] types
    .description
        PS> Find-Exception
    .description
        PS> Find-Exception -ShowReferences
    .outputs
         [string] | [Exception] | $null
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param(

        # Show 'BaseType's of exceptions, when referenced more than once
        # prints rankint to information, returns instances
        [Parameter()][switch]$CommonBases,

        # Show Common Exceptions list
        [Parameter()][switch]$ShowReferences,

        #
        [Parameter(position = 0)]
        [validateset('System.Exception', 'f')]
        [string[]]$Category
    )
    end {
        if ($CommonBases) {
            $query = Find-Exception
            | Group-Object BaseType
            | Sort-Object Count -Descending
            | Where-Object count -GT 1
            | ForEach-Object {
                [pscustomobject]@{
                    Count    = $_.Count
                    TypeName = $_.Name -as 'type' | Format-Typename -Brackets
                    Type     = $_.Name -as 'type'
                }
            }

            # pretty print to Info
            $query
            | Sort-Object Count, TypeName
            | Format-Table Count, TypeName, Type -auto
            | Out-Stri
            | Write-Information

            $query | Sort-Object BaseType

            return
        }

        if ($ShowReferences) {
            @'
- [Common Exceptions: dotnet core 3.1](https://docs.microsoft.com/en-us/dotnet/api/system.exception?view=netcore-3.1#choosing-standard-exceptions)
- [Common [Everything you'd ever want to know: Exceptions](https://powershellexplained.com/2017-04-10-Powershell-exceptions-everything-you-ever-wanted-to-know/?utm_source=blog&utm_medium=blog&utm_content=indexref)
'@
            return
        }
        $Query = @(
            Find-Type -FullName -match 'Exception'
            Find-Type -InheritsType 'System.Exception'
            Find-Type -Base 'System.Exception'
            Find-Type -ValueType 'System.Exception'
        ) | Sort-Object -Unique FullName

        "Found $($Query.Count) 'Exception' types" | Write-Information
        Write-Warning 'next: <C:\Users\cppmo_000\Documents\2021\Powershell\My_Github\Ninmonkey.Console\private\metadata\ExceptionTypes.metadata.ps1>'
        $Query
    }
}
