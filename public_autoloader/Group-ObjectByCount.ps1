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
        $Template = @{ Hex = '{0,-3:x}'  }
        0..255 | Iter->ByCount 8 | %{
            $_
            | Join-String -sep '' { $Template.Hex -f $_ }
            | Format-IndentText

        }

        # output
            0  1  2  3  4  5  6  7
            8  9  a  b  c  d  e  f
            10 11 12 13 14 15 16 17
            18 19 1a 1b 1c 1d 1e 1f
            20 21 22 23 24 25 26 27
            28 29 2a 2b 2c 2d 2e 2f
            30 31 32 33 34 35 36 37
            38 39 3a 3b 3c 3d 3e 3f
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
    .EXAMPLE
        $Template = @{ Hex = '{0,-3:x}'  }
        0..255 | Iter->ByCount 8 | %{
            $_
            | Join-String -sep '' { $Template.Hex -f $_ }
            | Format-Predent -PassThru -TabWidth 4
        } | Join-String -sep 'outer'
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
