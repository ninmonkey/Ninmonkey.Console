#Requires -Version 7
using namespace System.Collections.Generic
# uses pansies # soft,to prevent the requirement

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Invoke-PansiesExample'
    )
    $publicToExport.alias += @(
        # '' # Invoke-PansiesExample
    )
}


function Invoke-PansiesExample {
    <#
    .synopsis
        this hack hurts me more than you. experimenting with function references
    #>
    param(
        # which to invoke, else list functions if invalid
        [Alias('Name')]
        [string]$FunctionName,

        # list functions, quit.
        [switch]$ListOnly,

        # return the implementation instead of invoking
        [switch]$GetScriptBlock
    )
    begin {

        # prevent script-level shadowing
        class ExampleScriptBlock {
            <#
                .Example
                    PS>

                        $l.Add(
                            [ExampleScriptBlock]@{
                                ScriptBlock = { 'hi world' }
                                Name        = 'name'
                                Tags        = @('a', 'b')
                            } )
#>
            [String]$Name
            [ScriptBlock]$ScriptBlock
            [string[]]$Tags = @()
            [string]$Description = 'todo: Description: -> get child script block''s synopsis'
        }


        # $fn = [list[FunctionInfo]]::new()
        $fn = [list[ExampleScriptBlock]]::new()
        function _compareColorspacesBlock {
            'Hsl', 'Lch', 'Rgb', 'Lab', 'Xyz' | ForEach-Object {
                Get-Gradient red cyan -Width 30 -ColorSpace $_
                | ForEach-Object {
                    Write-Host ('a'..'z' + 'Z'..'Z'
                        | Get-Random) -fg 'white' -bg $_ -no
                }
                Write-Host
            }
        }
        # is delay binding equivalent ?
        # 'gi' returns a 'FunctionInfo'
        $fn.Add(
            [ExampleScriptBlock]@{
                ScriptBlock = Get-Item 'function:\_compareColorspacesBlock'
                | ForEach-Object ScriptBlock
                Name        = 'Compare-Colorspaces_Block'

                Description = 'Compare Generated Gradients by Colorspace'

                Tags        = @('ColorSpace', 'Gradient')
            } )
        $fn.Add(
            [ExampleScriptBlock]@{
                Name        = 'Colors_ManyCreationModes'

                Description = 'How many ways can you create [rgbcolor] or color escapes? A bunch'
                Tags        = @('Pwsh7', 'PSStyle', 'Gradient')
                ScriptBlock = {


                    Get-Gradient Red Blue
                    Get-Item bg:\red    # the main web and X11 names
                    Get-Item bg:\gray30 # gray 0..100

                    [RgbColor]::FromRgb(240, 120, 30)
                    [RgbColor]::FromRgb( [int32]45326)
                    [RgbColor]::FromRgb( 'CD5555' )
                    'Hsl', 'Lch', 'Rgb', 'Lab', 'Xyz' | ForEach-Object {
                        Get-Gradient red cyan -Width 30 -ColorSpace $_ | ForEach-Object { Write-Host ('a'..'z' + 'Z'..'Z' | Get-Random) -fg 'white' -bg $_ -no }
                        Write-Host
                    }
                }
            } )


    }
    process {
        if ($ListOnly) {
            return $fn
        }

        [ExampleScriptBlock]$found = $fn | Where-Object Name -Match $Name | Select-Object -First 1
        Write-Information "Func: ${Found.Name}"

        if ($GetScriptBlock) {
            return $found.ScriptBlock
        }

        & $found.ScriptBlock
    }
    end {
    }

}
