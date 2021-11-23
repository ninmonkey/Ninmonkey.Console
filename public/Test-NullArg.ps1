
function Test-NullArg {
    <#
    .synopsis
        test if args are actually null
    .example
        PS> 10, '', " ", 0, $null, "`u{0}" | Test-NullArg | Format-Table
    #>
    param(
        [Parameter(
            Mandatory, Position = 0,
            ValueFromPipeline)]
        [AllowNull()]
        [object]$InputObject # Not actually text, but,
    )
    begin {
        # finish mini pass over
    }

    process {
        $objIsNull = $null -eq $InputObject
        $meta = [ordered]@{
            Value              = $objIsNull ? '␀' : $InputObject # ␀
            Type               = $objIsNull ? '[Null]' : $InputObject.GetType().Name # ␀
            IsNull             = $null -eq $InputObject
            IsNullOrWhiteSpace = [string]::IsNullOrWhiteSpace( $InputObject )
            IsNullOrEmpty      = [string]::IsNullOrEmpty( $InputObject )
            AsString           = "'$InputObject'"
            ToString           = $objIsNull ? '␀' : $InputObject.ToString() | Join-String -SingleQuote
            CastString         = [string]$InputObject | Join-String -SingleQuote
            TestId             = $i++
            IsNullCodepoint    = $objIsNull ? $false : "`u{0}" -eq $InputObject
        }

        <#
            strip control chars from all outputs to make it safe to print
        #>
        $meta.keys.clone() | ForEach-Object {
            $curKey = $_
            if ( $meta[$curKey] -is 'String') {
                $meta[$curKey] = $meta[$curKey] | Format-ControlChar
                Write-Verbose "Value is a 'string' for $curKey"
            }
        }

        [pscustomobject]$Meta
    }
}
