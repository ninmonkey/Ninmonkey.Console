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
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param(

        # Show Common Exceptions list
        [Parameter()][switch]$ShowReferences
    )
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
    $Query
}
