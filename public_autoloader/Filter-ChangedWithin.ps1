#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-FdFind'
        'cleanFT'
        'Filter-AccessedWithin'
        'Filter-ModifiedWithin'

    )
    $publicToExport.alias += @(
        'FdNin' # 'Invoke-FdFind'
    )
}
# new

function cleanFT {
    <#
    .SYNOPSIS
        sugar for: $Foo | FT -Group {$True}
    .description
        lots of commands set a groupby, which can cause
        gci to take more than 1 line
    #>
    $Input | Format-Table -GroupBy { $True }
}

function Filter-ModifiedWithin {
    throw "Template that uses 'Filter-AccessedWithin' logic "
    'alias DM'
}

function Filter-AccessedWithin {
    <#
    .synopsis
        sugar for: filtering on access time
    .description
        sugar for: Get-Item | Where-Object { $_.lastAccessTime -gt (Get-Date).AddDays(-1) }
    .example
        # Now

            fd -e code-workspace # --changed-within 2weeks
            | Filter-AccessedWithin 1 Days

        # without:

          fd -e code-workspace # --changed-within 2weeks
            | Get-Item | Where-Object { $_.lastAccessTime -gt (Get-Date).AddDays(-1) }

    .outputs
          [string | None]

    #>
    [CmdletBinding()]
    param(
        # which item to filter
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        [Parameter(Mandatory, Position = 0)]
        $Value,

        [Parameter(Mandatory, Position = 1)]
        [ValidateSet('Months', 'Days', 'Hours', 'Minutes', 'Seconds')]
        [string]$Kind
    )

    begin {
        $now = [datetime]::now
        $edge = switch ($Kind) {
            'Months' {
                $now.AddMonths( - $Value )
            }
            'Days' {
                $now.AddDays( - $Value )
            }
            'Hours' {
                $now.AddHours( - $Value )
            }
            'Minutes' {
                $now.AddMinutes( - $Value )
            }
            'Seconds' {
                $now.AddSeconds( - $Value )
            }
        }

    }
    process {
        $item = Get-Item -ea ignore $InputObject
        if (! $Item ) {
            Write-Verbose "Failed Loading Item, Skipping... '$Item'"
            return
        }
        if ( $Item.LastAccessTime -gt $edge ) {
            Write-Debug "Keep. $($Item.LastAccessTime) > '$Edge'"
            return $Item
        } else {
            Write-Debug "Drop. -Not $($Item.LastAccessTime) > '$Edge'"
            return
        }


    }
    end {

    }
}
