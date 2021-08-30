using namespace System.Collections
$script:publicToExport.function += @(
    'Out-ReversePipeline'
)
$script:publicToExport.alias += @(
    'ReverseIt', 'Rev↵'
)
function Out-ReversePipeline {
    <#
    .synopsis
        reverse the pipeline
    .description
       .
    .example
          .
    .outputs
          [string | None]

    #>
    [Alias('ReverseIt', 'Rev↵')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject
    )

    begin {
        $InputObjectList = [list[object]]::new()
    }
    process {
        $InputObject | ForEach-Object {
            $InputObjectList.Add( $_ )
        }
    }
    end {
        # Reverses list in-place.
        #  It might be (should be)  more performant / less resources  to enumerate in reverse, instead.
        # docs: [generic List](https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.list-1?view=net-5.0#remarks)
        $InputObjectList.Reverse() | Out-Null
        $InputObjectList
    }
}
