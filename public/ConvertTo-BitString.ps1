function ConvertTo-BitString {
       <#
    .synopsis
    originally from: <Utility\ConvertTo-BitString>, then <https://gist.github.com/SeeminglyScience/6f7047f82fab792cc68d3b9e1e5a64c5>
    .notes
        currently the same, separate same. separate for dependency clarity
    .example
        PS> 0..3 | bits | Join-String -sep ' '

            0000.0000 0000.0001 0000.0010 0000.0011
    .example
        # For more see:
            <./test/public/ConvertTo-BitString.tests.ps1>
    #>
    [Alias('Bits')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline)]
        [psobject[]] $InputObject,

        [Parameter(Position = 0)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Padding,

        [Parameter(Position = 1)]
        [ValidateNotNull()]
        [AllowEmptyString()]
        [string] $ByteSeparator = ' ',

        [Parameter(Position = 2)]
        [ValidateNotNull()]
        [AllowEmptyString()]
        [string] $HalfByteSeparator = '.'
    )
    begin {
        $toBytes = [psdelegate]{
            ($a) => { [MemoryMarshal]::AsBytes([MemoryExtensions]::AsSpan($a)).ToArray() }
        }

        function GetBinaryString([psobject] $item) {
            $numeric = $item.psobject.BaseObject
            $numericType = $numeric.GetType()
            $isPrimitive = $numericType.IsPrimitive
            if (-not $isPrimitive) {
                if ($numericType.GetFields([BindingFlags]'Instance, Public, NonPublic').Length -gt 1) {
                    $PSCmdlet.WriteWarning(
                        'Structs with two or more fields may show inaccurately depending on field layout and processor endianness.')
                }
            }

            $delegateType = [Func`2].MakeGenericType(
                $numeric.GetType().MakeArrayType(),
                [byte[]])

            $toBytesCompiled = $toBytes -as $delegateType
            $bytes = $toBytesCompiled.Invoke($numeric)

            # Should always do this for LE? or only makes sense for primitives?
            if ([BitConverter]::IsLittleEndian) {
                [array]::Reverse($bytes)
            }

            $sb = [StringBuilder]::new([convert]::ToString($bytes[0], <# toBase: #> 2))
            for ($i = 1; $i -lt $bytes.Length; $i++) {
                $byte = $bytes[$i]
                $bits = [convert]::ToString($byte, <# toBase: #> 2)
                $null = $sb.Append($bits.PadLeft(8, [char]'0'))
            }

            $bits = $sb.ToString().TrimStart([char]'0')
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey((nameof{$Padding}))) {
                $padAmount = $Padding * 8
                if ($padAmount -ge $bits.Length) {
                    return $bits.PadLeft($Padding * 8, [char]'0')
                }
            }

            $padAmount = 8 - ($bits.Length % 8)
            if ($padAmount -eq 8) {
                return $bits
            }

            return $bits.PadLeft($padAmount + $bits.Length, [char]'0')
        }
    }
    process {
        foreach ($currentItem in $InputObject) {
            $binaryString = GetBinaryString $currentItem

            # yield
            $binaryString -replace
                '[01]{8}(?=.)', "`$0$ByteSeparator" -replace
                '[01]{4}(?=[01])', "`$0$HalfByteSeparator"
        }
    }
}