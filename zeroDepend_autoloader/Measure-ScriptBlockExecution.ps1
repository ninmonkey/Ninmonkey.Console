#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Measure-BasicScriptBlockExecution'
    )
    $publicToExport.alias += @(
        'n.TimeIt'
    )
}



class measureSbResult {
    hidden [scriptBlock]$ScriptBlock
    [timespan]$Elapsed
    [string]$Label
    [double]$Sec # should be a getter. does pwsh have one? a scriptproperty without update-typedata
    [double]$Ms
    [int]$Order
    # [long]$Ticks

    measureSbResult( [ScriptBlock]$ScriptBlock, [Timespan]$Elapsed, [string]$Label, [int]$Order ) {
        $this.ScriptBlock = $ScriptBlock
        $this.Elapsed = $Elapsed
        $this.Label = $Label ?? ''
        $this.Sec = $elapsed.TotalSeconds
        $this.Ms = $elapsed.TotalMilliseconds
        $this.Order = $Order
        # $this.Ticks = 0
    }
}

function Measure-BasicScriptBlockExecution {
    <#
    .synopsis
        gives a very rough measure of time taken to execute. use another function if precision matters. This is for sugar.
    .example
        0..3 |  %{ nb.TimeIt -ScriptBlock { sleep 0.2 } -Label 'bob' }|ft

        Elapsed          Label  Sec     Ms Order
        -------          -----  ---     -- -----
        00:00:00.2146765 bob   0.21 214.68     0
        00:00:00.2017461 bob   0.20 201.75     1
        00:00:00.2011267 bob   0.20 201.13     2
        00:00:00.2001124 bob   0.20 200.11     3
    #>
    # 'n.MeasureScriptBlockExecution'
    [Alias('n.TimeIt')]
    [CmdletBinding()]
    param(
        # scriptblock to execute and measure
        [Alias('SB', 'InputObject')]
        [Parameter(Mandatory, ValueFromPipeline, position = 0)]
        [ScriptBlock[]]$ScriptBlock,

        [string]$Label
        # ,
        # # number of times to execute the scriptblock
        # [int]$Iterations = 1
    )
    begin {
        $script:__measureOrder ??= 0

        [Collections.Generic.List[Object]]$Items = @()
        [Collections.Generic.List[measureSbResult]]$Results = @()
    }
    process {
        foreach ($Sb in $ScriptBlock) {

            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            # $sb.Invoke() # ?
            & $sb #
            $sw.Stop()

            $Results.add(
                [measureSbResult]::new( $sb, $sw.Elapsed, $Label, (
                    ($script:__measureOrder++)
                    ))
            )
            # [measureSbResult]@{
            #     ScriptBlock = $sb
            #     Elapsed     = $sw.Elapsed
            #     Sec         = $sw.Elapsed.TotalSeconds
            #     Ms          = $sw.Elapsed.TotalMilliseconds
            #     Label       = $Label
            # })
        }
    }
    end {
        return $results
    }

}

# class measureSbResult {
#     hidden [scriptBlock]$ScriptBlock
#     [timespan]$Elapsed
#     [string]$Label
#     [double]$Sec # should be a getter. does pwsh have one? a scriptproperty without update-typedata
#     [double]$Ms
#     # [long]$Ticks

#     measureSbResult( [ScriptBlock]$ScriptBlock, [Timespan]$Elapsed, [string]$Label ) {
#         $this.ScriptBlock = $ScriptBlock
#         $this.Elapsed = $Elapsed
#         $this.Label = $Label ?? ''
#         $this.Sec = $elapsed.TotalSeconds
#         $this.Ms = $elapsed.TotalMilliseconds
#         # $this.Ticks = 0
#     }
# }

# function Measure-BasicScriptBlockExecution {
#     <#
#     .synopsis
#         gives a very rough measure of time taken to execute. use another function if precision matters. This is for sugar.
#     #>
#     [OutputType('[measureSbResult[]]', 'System.Collections.Generic.List[measureSbResult]')]
#     [Alias('n.TimeIt')]
#     [CmdletBinding()]
#     param(
#         # scriptblock to execute and measure
#         [Alias('SB', 'InputObject')]
#         [Parameter(Mandatory, ValueFromPipeline, position = 0)]
#         [ScriptBlock[]]$ScriptBlock,

#         [string]$Label
#         # ,
#         # # number of times to execute the scriptblock
#         # [int]$Iterations = 1
#     )
#     begin {
#         # [Collections.Generic.List[Object]]$Items = @()
#         [Collections.Generic.List[measureSbResult]]$Results = @()
#     }
#     process {
#         foreach ($Sb in $ScriptBlock) {

#             $sw = [System.Diagnostics.Stopwatch]::StartNew()
#             # $sb.Invoke() # ?
#             & $sb #
#             $sw.Stop()

#             $Results.add(
#                 [measureSbResult]::new( $sb, $sw.Elapsed, $Label)
#             )
#             # [measureSbResult]@{
#             #     ScriptBlock = $sb
#             #     Elapsed     = $sw.Elapsed
#             #     Sec         = $sw.Elapsed.TotalSeconds
#             #     Ms          = $sw.Elapsed.TotalMilliseconds
#             #     Label       = $Label
#             # })
#         }
#     }
#     end {
#         return $results
#     }

# }