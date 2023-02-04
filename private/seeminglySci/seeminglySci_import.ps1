using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Text

using namespace System.Management.Automation.Language
using namespace System

<#
see also:
    <https://github.com/SeeminglyScience/dotfiles/blob/a7a9bcf3624efe5be4988922ba2e35e8ff2fcfd8/PowerShell%2FUtility.psm1#L121>
#>

# [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Target = '??')]
param()
write-warning '2022-09-03 -- ensure updated profile 🐛'

"[1] Need to auto-clone latest Sci Dotfile [2] ensure that namespace continue fix is applied" | New-Text -bg 'gray50' -fg 'gray30' | Write-Warning
<#
    [section]: alias
#>

# at           = Select-ObjectIndex
# skip         = Skip-Object
# default      = Get-TypeDefaultValue
# nameof       = Get-ElementNamed
# cast         = ConvertTo-Array
# append       = Join-After
# prepend      = Join-Before
# e            = Get-BaseException
# se           = Show-Exception
# show         = Show-FullObject
# tostring     = ConvertTo-String
# await        = Wait-AsyncResult
# ??           = Invoke-Conditional
# code         = Invoke-VSCode
# ishim        = Install-Shim
# p            = Set-AndPass
# up           = Start-ElevatedSession
# sms          = Show-MemberSource
# emi          = Expand-MemberInfo
# pslambda     = Invoke-PSLambda

# $env:HOMEDRIVE = $env:SystemDrive
# $env:HOMEPATH = $env:USERPROFILE | Split-Path -NoQualifier

# $__IsWindows =
#     -not $PSVersionTable['PSEdition'] -or
#     $PSVersionTable['PSEdition'] -eq 'Desktop' -or
#     $PSVersionTable['Platform'] -eq 'Win32NT'

# $__IsVSCode = $env:TERM_PROGRAM -eq 'vscode'

# $__IsTerminal = [bool] $env:WS_SESSION

# $__IsConHost = -not ($__IsVSCode -or $__IsTerminal)

<#
    [section]: Imports
#>

<#
    [section]: main
#>

filter decimal { foreach ($currentItem in $PSItem) { Convert-Object -InputObject $currentItem -Type ([decimal]) } }
filter double { foreach ($currentItem in $PSItem) { Convert-Object -InputObject $currentItem -Type ([double]) } }
filter single { foreach ($currentItem in $PSItem) { Convert-Object -InputObject $currentItem -Type ([single]) } }
filter ulong { foreach ($currentItem in $PSItem) { Convert-Object -InputObject $currentItem -Type ([uint64]) } }
filter long { foreach ($currentItem in $PSItem) { Convert-Object -InputObject $currentItem -Type ([int64]) } }
filter uint { foreach ($currentItem in $PSItem) { Convert-Object -InputObject $currentItem -Type ([uint32]) } }
filter int { foreach ($currentItem in $PSItem) { Convert-Object -InputObject $currentItem -Type ([int]) } }
filter ushort { foreach ($currentItem in $PSItem) { Convert-Object -InputObject $currentItem -Type ([uint16]) } }
filter short { foreach ($currentItem in $PSItem) { Convert-Object -InputObject $currentItem -Type ([int16]) } }
filter byte { foreach ($currentItem in $PSItem) { Convert-Object -InputObject $currentItem -Type ([byte]) } }
filter sbyte { foreach ($currentItem in $PSItem) { Convert-Object -InputObject $currentItem -Type ([sbyte]) } }

write-warning "update imports /w new Sci functions [Ninmonkey.Console/private/SeeminglySci/*]"

$script:WellKnownNumericTypes = [type[]](
    [byte],
    [sbyte],
    [int16],
    [uint16],
    [int],
    [uint32],
    [int64],
    [uint64],
    [single],
    [double],
    [decimal],
    [bigint])

function ConvertTo-SciNumber {
    # [Alias('Number')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline, Position = 0)]
        [psobject] $InputObject
    )
    process {
        foreach ($currentItem in $InputObject) {
            if ($currentItem -is [Enum]) {
                # yield
                $currentItem.value__
                continue
            }

            if ($currentItem -isnot [ValueType]) {
                # yield
                $currentItem -as [int]
                continue
            }

            if ([array]::IndexOf($script:WellKnownNumericTypes, $currentItem.GetType()) -eq -1) {
                # yield
                $currentItem -as [int]
                continue
            }

            # yield
            $currentItem
        }
    }
}


function ConvertTo-SSciHexString {
    [Alias('Hex')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline)]
        [psobject[]] $InputObject,

        [Parameter(Position = 0)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Padding
    )
    process {
        foreach ($currentItem in $InputObject) {
            $numeric = number $currentItem

            if ($PSBoundParameters.ContainsKey((nameof { $Padding }))) {
                "0x{0:X$Padding}" -f $numeric
                continue
            }

            '0x{0:x}' -f $numeric
        }
    }
}


function ConvertTo-SSciBase64String {
    <#
    #>
    [Alias('Base64')] # was also 'base'
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline, Position = 0)]
        [AllowEmptyString()]
        [AllowNull()]
        [string] $InputObject,

        [Parameter()]
        [ArgumentCompleter([EncodingArgumentCompleter])]
        [EncodingArgumentConverter()]
        [Encoding] $Encoding
    )
    begin {
        if ($PSBoundParameters.ContainsKey((nameof { $Encoding }))) {
            $userEncoding = $Encoding
            return
        }

        $userEncoding = [Encoding]::Unicode
    }
    process {
        if ([string]::IsNullOrEmpty($InputObject)) {
            return
        }

        return [convert]::ToBase64String($userEncoding.GetBytes($InputObject))
    }
}

function Get-SciElementName {
    [Alias('NameOf')]
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory)]
        [ValidateNotNull()]
        [ScriptBlock] $Expression
    )
    end {
        if ($Expression.Ast.EndBlock.Statements.Count -eq 0) {
            return
        }

        $firstElement = $Expression.Ast.EndBlock.Statements[0].PipelineElements[0]
        if ($firstElement.Expression.VariablePath.UserPath) {
            return $firstElement.Expression.VariablePath.UserPath
        }

        if ($firstElement.Expression.Member) {
            return $firstElement.Expression.Member.SafeGetValue()
        }

        if ($firstElement.GetCommandName) {
            return $firstElement.GetCommandName()
        }

        if ($firstElement.Expression.TypeName.FullName) {
            return $firstElement.Expression.TypeName.FullName
        }
    }
}

# function Get-EnumInfo {
#     <#
#     .description
#         Displays name mappings to values
#     .example
#         PS> [IO.Compression.CompressionMode] | Get-EnumInfo
#     #>
#     [CmdletBinding()]
#     param(
#         [Parameter(ValueFromPipeline)]
#         [psobject] $InputObject
#     )
#     begin {
#         $alreadyProcessed = $null
#     }
#     process {
#         if ($null -eq $InputObject) {
#             return
#         }

#         if ($null -eq $alreadyProcessed -and $MyInvocation.ExpectingInput) {
#             $alreadyProcessed = [HashSet[type]]::new()
#         }

#         $enumType = $InputObject.psobject.BaseObject
#         if (-not ($enumType -is [Type] -and $enumType.IsEnum)) {
#             $enumType = $enumType.GetType()
#         }

#         if (-not ($enumType -is [Type] -and $enumType.IsEnum)) {
#             return
#         }

#         if ($MyInvocation.ExpectingInput -and -not $alreadyProcessed.Add($enumType)) {
#             return
#         }

#         $names = [enum]::GetNames($enumType)
#         $values = [enum]::GetValues($enumType)

#         $lastBits = bits -InputObject $values[-1]
#         $bitsPadding = ($lastBits -replace '[\. ]').Length / 8
#         $hexPadding = (hex -InputObject $values[-1]).Length - 2
#         for ($i = 0; $i -lt $names.Length; $i++) {
#             $value = $values[$i].value__
#             $info = [PSCustomObject]@{
#                 PSTypeName = 'UtilityProfile.EnumValueInfo'
#                 EnumType   = $enumType
#                 Name       = $names[$i]
#                 Value      = $value
#                 Hex        = hex -InputObject $value -Padding $hexPadding
#                 Bits       = bits -InputObject $value -Padding $bitsPadding
#             }

#             $info.psobject.Members.Add(
#                 [PSMemberSet]::new(
#                     'PSStandardMembers',
#                     [PSMemberInfo[]](
#                         [PSPropertySet]::new(
#                             'DefaultDisplayPropertySet',
#                             [string[]]('Name', 'Value', 'Hex', 'Bits')))))

#             # yield
#             $info
#         }
#     }
# }

function Get-TypeDefaultValue {
    [Alias('Default')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [ArgumentCompleter([ClassExplorer.TypeArgumentCompleter])]
        [type] $Type
    )
    end {
        if (-not $Type.IsValueType) {
            return $null
        }

        $PSCmdlet.WriteObject(
            [Activator]::CreateInstance($Type),
            <# enumerateCollection: #> $false)
    }
}


function Convert-Object {
    [Alias('Convert')]
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(ValueFromPipeline)]
        [psobject] $InputObject,

        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNull()]
        [ArgumentCompleter([ClassExplorer.TypeArgumentCompleter])]
        [type] $Type
    )
    process {
        throw "who uses me?"
        if ($null -eq $InputObject) {
            return
        }

        $convertedValue = default($Type)
        if ([LanguagePrimitives]::TryConvertTo($InputObject, $Type, [ref] $convertedValue)) {
            return $convertedValue
        }
    }
}
