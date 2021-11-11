$script:publicToExport.function += @(
    'Assert-CommandType'
)
$script:publicToExport.alias += @(    
    # 'Where-CommandType'
    '?CommandType'
    'Filter->CommandType'
)
function Assert-CommandType {
    <#
    .synopsis
        Stuff
    .description
       .
    .example
          .
    .link
        System.Management.Automation.CommandTypes
    .outputs
          [bool]
    
    #>
    [Alias('Where-CommandType', '?CommandType', 'Filter->CommandType')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        # object
        [Parameter(Mandatory, Position = 0)]
        [object]$InputObject,

        # must be one of these types
        [Alias('Is')]
        [Parameter()]
        [Management.Automation.CommandTypes[]]$IsOfType,

        # must not be be of these types
        [Alias('IsNot')]
        [Parameter()]
        [Management.Automation.CommandTypes[]]$IsNotOfType
    )
    
    begin {}
    process {
        $InputObject.CommandType | str Prefix 'CommandType: ' | Write-Debug
        $IsOfType | ForEach-Object { 
            
            
            $curType = $_
            $curType | str prefix 'compare: Is' | Write-Color 'green' | Write-Debug
            if ($InputObject.CommandType -eq $curType) {

                '{0} : {1}' -f @(
                    $InputObject.CommandType
                    $curType
                )
                | str prefix 'compare: $true' | Write-Color 'orange' | Write-Debug            
                $true; return 
            }
            'compare: $true' | Write-Color 'green' | Write-Debug            
        }
        $IsNotOfType | ForEach-Object { 
            $curType = $_
            $curType | str prefix 'compare: IsNot' | Write-Color red | Write-Debug
            if ($InputObject.CommandType -eq $curType) {
                'compare: $false' | Write-Color 'red' | Write-Debug            
                $false; return 
            }
        }
        $true  #         
    }
    end {}
}

# $IsType
#  | Get-EnumInfo
# $InputObject -notin @('Alias', 'Application')