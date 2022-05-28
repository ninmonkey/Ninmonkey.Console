using namespace System.Diagnostics.CodeAnalysis

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Inspect-PathInfoStack'
    )
    $publicToExport.alias += @(
        # 'Get-PathInfo' # 'Inspect-PathInfoStack'
    )
}

# [SuppressMessage('PSUseApprovedVerbs', 'InteractiveCommand')]
function Inspect-PathInfoStack {
    <#
    .synopsis
        inspect the state of multiple PathInfo stacks to debug / confirm pathinfo-locations
    .link
        Ninmonkey.Console\Push-Location
    .link
        https://docs.microsoft.com/en-us/dotnet/api/System.Management.Automation.PathInfo
    .link
        https://docs.microsoft.com/en-us/dotnet/api/System.Management.Automation.PathInfoStack
    #>


    [Alias('Get-PathInfo')]
    [cmdletbinding()]
    param(
        [string]$StackName
    )

    Hr

    $dbg = @{
        'Get-Location'                  = Get-Location
        'Get-Location -StackName $null' = Get-Location -StackName $Null
        'Get-Location -Stack | csv'     = Get-Location -Stack | Csv2
        '@( Get-Location -Stack )[0]'   = @(Get-Location -Stack)[0]
        'PathInfoStack Count'           = (Get-Location -Stack ).count
    }

    if ($StackName) {
        $label = 'Get-Location -StackName {0}' -f $StackName
        $result = Get-Location -StackName $StackName
        $dbg.Add( $Label, $result  )
    }

    $dbg | Format-HashTable -FormatMode Pair
    Hr
}