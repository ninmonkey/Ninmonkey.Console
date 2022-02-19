using namespace System.Collections.Generic

#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Group-ObjectByCount'
    )
    $publicToExport.alias += @(
        'Iter->ByCount' # 'Group-ObjectByCount'
        'GroupCount' # 'Group-ObjectByCount'
    )
}


function Group-ObjectByCount {
    <#
    .synopsis
        collects items and emits them in groups without having to enumerate the full pipeline
    .description


    .example

        0..6 GroupByCount 3 returns:
            @(
                0..2
                3..5
                6
            )

    .example
            0..6 GroupByCount 3 returns:
            @(
                0..2
                3..5
                6
            )

          .
    .outputs
          [object[]]

    #>
    [Alias(
        'Iter->ByCount',
        'GroupCount'
    )]
    [OutputType( [object[]] )]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        # group size
        [alias('Size')]
        [parameter(Mandatory, Position = 0)]
        [uint]$Count,

        # objects
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject

    )

    begin {
        $buffer = [System.Collections.Generic.List[object]]::new()
    }
    process {
        $buffer.Add($InputObject)
        if ($buffer.Count -ge $Count) {
            , @($buffer)
            $buffer.Clear()
            return
        }
    }
    end {
        'ended with?', $buffer.Count -join ' ' | Write-Debug
        , @( $buffer)
    }
}
