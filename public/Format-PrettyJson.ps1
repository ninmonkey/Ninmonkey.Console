
function Format-PrettyJson {
    <#
    .synopsis
        piping objects will convert to Json with syntax highlighting and a label
    .description
        an easy way to visualise nested arrays (or to confirm they are not flat)
    .example
        PS>
            $Sample = @(1, 4, @(0..2))
            $Sample | Format-PrettyJson 'Nested'
    .notes
        Should it be ConvertTo-PrettyJson ?
    #>

    [Alias('PrettyJson', 'Json🎨')]
    param(
        # input array
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [object]$InputObject,

        # Name / description
        [Parameter(Position = 0)]
        [string]$Name = 'Json',

        # Do not colorize
        [Parameter()][switch]$NoColor
    )
    begin {
        $objList = [list[object]]::new()
        $useColor = $true

        try {
            Get-NativeCommand pygmentize -ea Stop | Out-Null
        } catch {
            $useColor = $false
        }
    }
    process {
        $objList.Add( $InputObject )
    }
    end {
        if (! $useColor) {
            $objList | ConvertTo-Json | Label $Name
            return
        }

        $objList | ConvertTo-Json
        | Join-String -sep "`n" # required for pygment
        # | pygmentize.exe -l json # update to use get-native
        | pygmentize.exe -l json # update to use get-native
    }
}
