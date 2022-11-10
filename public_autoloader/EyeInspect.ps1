#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        '_inspectMacro'  # 'Eye'
    )
    $publicToExport.alias += @(
        'Eye' # '_inspectMacro'
    )
}

function _inspectMacro { 
    <#
    .synopsis
       quickly dump PSObject and type info
    .DESCRIPTION 

    #>
    [Alias('Eye')]
    [CmdletBinding()]
    param( 
        [Parameter(Mandatory)] $Target,
        [switch]$Short

        # [switch]$PassThru
    )
    # using -unique to only show one signature per Name
    if ($Short) { 
        $target | Find-Member | Sort-Object Name -Unique | Format-Table -group MemberType
    }
    else {     
        $target | Find-Member | Sort-Object Name | Format-Table -group MemberType
    }
    Write-ConsoleHorizontalRule

    $target | Inspect-ObjectProperty
    | sort name
    | ? Type -NotMatch 'String' | Format-Table Name, Type, Value
}
