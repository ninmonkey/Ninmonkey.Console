#Requires -Version 7
$publicToExport.function += @(
    'Out-NinGridView'
)
$publicToExport.alias += @(
    'Out-Grid'
)
function Out-NinGridView {
    <#
    .synopsis
        Regular Out-GridView, except that it shows on top of windows
    .description
        next: test if -passthru blocks the window restore or not
    .notes
        .
    .example
        PS> Get-Processs | Out-NinGridView
    #>
    [Alias('Out-Grid')]
    [cmdletbinding()]
    param(
        # inputobject[s]
        [Parameter(Mandatory)]
        [object]$InputObject
    )

    begin {
        $objList = [list[object]]::new()
    }
    process {
        $InputObject | ForEach-Object {
            $objList.Add( $_ )
        }
    }
    end {
        # Label 'status' '=> piping...'
        $objList
        | Out-GridView #-PassThru

        # Label 'status' '=> restore'
        if (Get-Command -ea ignore 'Window->Get') {

            $w = Window->Get '*Out-GridView*'
            $w | Minimize-Window
            # Start-Sleep 0.1
            $w | Restore-Window
        }
        # Label 'status' '=> Done'
    }
}

# works
if ($false) {
    Get-ChildItem . | Out-NinGridView
    Start-Sleep 0.3
    Get-ChildItem . | Select-Object * | Out-NinGridView
}
