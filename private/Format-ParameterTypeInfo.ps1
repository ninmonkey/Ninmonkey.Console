using namespace System.Management.Automation


function _Format-ParameterTypeInfo {
    <#
    .description
        formats [System.Management.Automation.ParameterMetadata]
    #>
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = '[ParameterMetadata] instance')]
        $InputObject
    )

    begin {
        h2 'yay'
        Write-Warning 'wip'
    }
    process {

        $InputObject.GetEnumerator() | ForEach-Object {

            # is a: [ParameterMetadata]
            $curParam = $_
            $curName = $curParam.Key
            $curValue = $curParam.Value
            $hashParam = @{
                Name       = $curName
                Type       = $curValue.ParameterType
                ParamSets  = $curValue.ParameterSets
                IsDynamic  = $curValue.IsDynamic
                Aliases    = $curValue.Aliases
                Attributes = $curValue.Attributes
                IsSwitch   = $curVal.SwitchParameter

            }
            [pscustomobject]$hashParam
        }
    }
}

$Sample = @{
    FunctionInfo_WithParam = Get-Command * | Where-Object {
        $_ -is 'FunctionInfo' -and $null -ne $_.Version -and $_.Parameters.PSBase.Count -gt 0
    } | Select-Object -First 1 -Wait
}
$g_paramDict = $Sample.FunctionInfo_WithParam.Parameters
$g_paramSingle = $Sample.FunctionInfo_WithParam.Parameters.GetEnumerator() | Select-Object -First 1 -ExpandProperty Value

_Format-ParameterTypeInfo $g_paramDict
