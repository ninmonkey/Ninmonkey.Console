﻿Function Format-FileSize {
    <#
    .DESCRIPTION
    Formats bytes as humanized sizes
    .NOTES
    todo:
        - nicely handle null values (just ignore)
        - jformat table with alighn  = right

    Original was based on: https://github.com/chocolatey/choco/blob/master/src/chocolatey.resources/helpers/functions/Format-FileSize.ps1
    #>
    [cmdletbinding()]
    param (
        [Parameter(Mandatory, Position = 0,
            ValueFromPipeline,
            HelpMessage = "Size in bytes")]

        [int64] $Size
    )

    process {
        # if ($null -eq $Size) { # this is never hit using ls
        #     Write-Warning 'null'
        # }
        Foreach ($unit in @('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB')) {
            If ($size -lt 1024) {
                return [string]::Format("{0:0.##} {1}", $size, $unit)
            }
            $size /= 1024
        }
        [string]::Format("{0:0.##} YB", $size)

    }

}