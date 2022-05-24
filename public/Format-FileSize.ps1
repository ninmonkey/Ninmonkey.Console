Function Format-FileSize {
    <#
    .DESCRIPTION
    Formats bytes as humanized sizes
    .NOTES
    todo:
        - nicely handle null values (just ignore)
        - format table with align  = right

    Original was based on: https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Format-FileSize.ps1
    #>
    [cmdletbinding()]
    param (
        # size in Bytes
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [int64] $Size,

        # future nin parameter type
        # [1] tooltip of format string show an actual usage of the template
        [Parameter()]
        [ArgumentCompletions(
            "'{0:n2} {1}'",
            "'{0:0.##} {1}'"
        )]
        [String]$FormatString = '{0:n2} {1}'
    )

    begin {
        if ( [string]::IsNullOrWhiteSpace($FormatString) ) {
            $template = '{0:0.##} {1}'
        } else {
            $template = $FormatString
        }
    }
    process {


        Foreach ($unit in @('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB')) {
            If ($size -lt 1024) {
                return [string]::Format($template, $size, $unit)
            }
            $size /= 1024
        }
        [string]::Format('{0:0.##} YB', $size)
    }
}
