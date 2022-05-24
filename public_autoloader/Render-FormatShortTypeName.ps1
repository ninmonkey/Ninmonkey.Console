

if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'Render-ShortTypeName'
        'Func-FormatTypeNameSummary'
    )
    $script:publicToExport.alias += @(
        'renderShortTypeName' # 'Render-ShortTypeName'

    )
}


function Func-FormatTypeNameSummary {
    # print type plus pstypenames
    Write-Warning 'see Dev.Nin\Inspect->TypeInfo'
}
function Render-ShortTypeName {

    <#
    .synopsis
        no dependencies, cleanup a single typeinfo
    .example
        PS> Get-Location | ConvertTo-BreadCrumb

    .notes
        warning: isn't reseting colors at end of line

        render-* implies ansi colors

    .link
        Ninmonkey.Console\Format-ShortTypeName
    .link
        Ninmonkey.Console\Render-ShortTypeName




    #>

    [Alias(
        'renderShortTypeName'
        # 'renderTypeName'
    )]
    [OutputType('System.String')]
    param(
        # can be a path, string, path separators work either wayBath can be
        # Can be an instance, or a type
        [Alias('TypeName', 'Path')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [object]$InputObject
    )
    begin {
        $regexReplace = @(
            @{
                'Pattern' = '^' + [regex]::escape( 'System.Management.Automation' )
                'Replace' = "${fg:gray50}sma.${fg:reset}" | ForEach-Object tostring
            }
            @{
                'Pattern' = '^System.'
                'Replace' = ''
            }

        )


    }
    process {
        # future: resolve->TypeInfo
        # passthrough, resolve->Typeinfo does exist
        $InputObject.GetType().FullName | Join-String -op 'Input: TypeName' | Write-Verbose
        $str_tinfo = if ($InputObject -is 'type') {
            Write-Debug '-> -Is [type]'
            $InputObject | ForEach-Object FullName
        } elseif ($InputObject -as 'type') {
            Write-Debug '-> -As [type]'
            $InputObject -as 'type' | ForEach-Object FullName
        } elseif ($InputObject -is 'string') {
            Write-Debug '-> -Is [String]'
            $InputObject
        } else {
            Write-Debug '-> final else, is object'
            $InputObject.GetType() | ForEach-Object FullName
        }
        Write-Debug "'original: '$str_tinfo' "

        $accum = $str_tinfo
        foreach ($p in $regexReplace) {
            Write-Debug "'accum: '$accum' "
            $accum = $Accum -replace $p.Pattern, $p.Replace
        }
        Write-Debug "'final: '$accum' "
        return $accum
    }

    end {

    }

}
