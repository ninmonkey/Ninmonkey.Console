using namespace System.Management.Automation

function Get-EnumInfo {
    <#
    .synopsis
        Displays name mappings to values
    .description
        (warning: check updated version on SeeminglySci's profile)
    .example
        bug:
        [ValidateRange] | Get-EnumInfo
        # returns nothing
        # was:
        #   ([ValidateRange]).BaseType
            [ValidateEnumeratedArgumentsAttribute]
        ?? info
            🐒> ([ValidateRange]).CustomAttributes.ConstructorArguments

            ArgumentType            Value
            ------------            -----
            System.AttributeTargets   384

    .example
        🐒> [IO.Compression.CompressionMode] | Get-EnumInfo

            Name       Value Hex Bits
            ----       ----- --- ----
            Decompress     0 0x0 0000.0000
            Compress       1 0x1 0000.0001

        🐒> [ConsoleColor] | Get-EnumInfo

            Name        Value Hex Bits
            ----        ----- --- ----
            Black           0 0x0 0000.0000
            DarkBlue        1 0x1 0000.0001
            DarkGreen       2 0x2 0000.0010
            DarkCyan        3 0x3 0000.0011
            ... cont. ...
    #>
    [Alias('EnumInfo')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [psobject] $InputObject
    )
    begin {
        $alreadyProcessed = $null
    }
    process {
        if ($null -eq $InputObject) {
            return
        }

        if ($null -eq $alreadyProcessed -and $MyInvocation.ExpectingInput) {
            $alreadyProcessed = [HashSet[type]]::new()
        }

        $enumType = $InputObject.psobject.BaseObject
        if (-not ($enumType -is [Type] -and $enumType.IsEnum)) {
            $enumType = $enumType.GetType()
        }

        if (-not ($enumType -is [Type] -and $enumType.IsEnum)) {
            return
        }

        if ($MyInvocation.ExpectingInput -and -not $alreadyProcessed.Add($enumType)) {
            return
        }

        $names = [enum]::GetNames($enumType)
        $values = [enum]::GetValues($enumType)

        $lastBits = Bits -InputObject $values[-1]
        $bitsPadding = ($lastBits -replace '[\. ]').Length / 8
        $hexPadding = (Hex -InputObject $values[-1]).Length - 2
        for ($i = 0; $i -lt $names.Length; $i++) {
            $value = $values[$i].value__
            $info = [PSCustomObject]@{
                PSTypeName = 'UtilityProfile.EnumValueInfo'
                EnumType   = $enumType
                Name       = $names[$i]
                Value      = $value
                Hex        = Hex -InputObject $value -Padding $hexPadding
                Bits       = Bits -InputObject $value -Padding $bitsPadding
            }

            $info.psobject.Members.Add(
                [PSMemberSet]::new(
                    'PSStandardMembers',
                    [PSMemberInfo[]](
                        [PSPropertySet]::new(
                            'DefaultDisplayPropertySet',
                            [string[]]('Name', 'Value', 'Hex', 'Bits')))))

            # yield
            $info
        }
    }
}
