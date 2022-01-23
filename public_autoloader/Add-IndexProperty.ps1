#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Add-IndexProperty'
    )
    $publicToExport.alias += @(

    )
}

function Add-IndexProperty {
    <#
    .synopsis
        Add a unique Id column (ie: Index column) for a list of objects
    .description
        Add a unique Id property/column for a list of objects
        If property exists, write-error, and skip item

        With -Force, you may overwrite the property
    .example
        .
    .example
        PS> # test
            ls fg: | Get-Random -Count 3
            | Add-IndexProperty
            | ft Id, *Name*

            hr
            ls fg: | Get-Random -Count 3
            | Add-IndexProperty
            | Add-IndexProperty -Offset 99  -Force -ea ignore
            | ft Id, *Name*

    #>
    # [Alias('')]
    param(
        # Object to modify
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [object]$InputObject,

        # initial count to start as, default = 0
        [Parameter()][int]$Offset = 0,

        # Which Property name to use, else 'Id'
        [Parameter()][string]$PropertyName = 'Id',

        # Force property write?
        [Parameter()][switch]$Force
    )
    begin {
        # $isFirstIter = $true
        $Index = $Offset
    }
    process {
        $Target = $InputObject
        $addMemberSplat = @{
            NotePropertyName  = $PropertyName
            NotePropertyValue = $Index++
            PassThru          = $true
        }
        if ($Force) {
            $addMemberSplat['Force'] = $Force
            $ErrorAction = 'Continue'
        }
        if ($target.PSObject.Properties.Name -contains $PropertyName) {
            $writeErrorSplat = @{
                TargetObject = $Target
                Message      = "Object already has the property '$PropertyName'"
            }
            if ($Force) {
                $writeErrorSplat['ErrorAction'] = 'SilentlyContinue'
            } else {
                $writeErrorSplat['ErrorAction'] = 'Continue'

            }

            Write-Error @writeErrorSplat
            if (! $Force) {
                $Target
                return
            }
        }

        $Target | Add-Member @addMemberSplat

    }
}


if (! $publicToExport) {
    # ...
}
