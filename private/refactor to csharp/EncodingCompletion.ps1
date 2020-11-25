using namespace System.Collections
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using namespace System.Text


# using namespace System.Collections
# using namespace System.Management.Automation
# using namespace System.Text

# using namespace System.Management.Automation.Language
# using namespace System


# see: <https://github.com/vexx32/PSKoans/blob/073998d26a8147effc12c6ec0e3be9fdf5924eda/PSKoans/Classes/KoanAttribute.ps1>

Write-Warning 'refactor: see also
- <https://github.com/SeeminglyScience/ClassExplorer/blob/209564a1a90281cbdda667774e4bd6e1ce449610/src%2FClassExplorer%2FNamespaceArgumentCompleter.cs#L5>
- <https://github.com/vexx32/PSKoans/blob/073998d26a8147effc12c6ec0e3be9fdf5924eda/PSKoans/Classes/KoanAttribute.ps1>
'


<#
from original:
    # Terrible dirty hack to get around using non-exported classes in some of the function
    # parameter blocks. Don't use this in a real module pls
    # $typeAccel = [ref].Assembly.GetType('System.Management.Automation.TypeAccelerators')
    # $typeAccel::Add('EncodingArgumentConverterAttribute', [EncodingArgumentConverterAttribute])
    # $typeAccel::Add('EncodingArgumentConverter', [EncodingArgumentConverterAttribute])
    # $typeAccel::Add('EncodingArgumentCompleter', [EncodingArgumentCompleter])
#>

# Add-Type -TypeDefinition
$TypeDefScript = @'
class EncodingArgumentCompleter : IArgumentCompleter {
    hidden static [string[]] $s_encodings

    static EncodingArgumentCompleter() {
        $allEncodings = [Encoding]::GetEncodings()
        $names = [string[]]::new($allEncodings.Length + 7)
        $names[0] = 'ASCII'
        $names[1] = 'BigEndianUnicode'
        $names[2] = 'Default'
        $names[3] = 'Unicode'
        $names[4] = 'UTF32'
        $names[5] = 'UTF7'
        $names[6] = 'UTF8'

        for ($i = 0; $i -lt $allEncodings.Length; $i++) {
            $names[$i + 7] = $allEncodings[$i].Name
        }

        [EncodingArgumentCompleter]::s_encodings = $names
    }

    [IEnumerable[CompletionResult]] CompleteArgument(
        # [System.Collections.IEnumerable[CompletionResult]] CompleteArgument(
        [string] $commandName,
        [string] $parameterName,
        [string] $wordToComplete,
        [CommandAst] $commandAst,
        [IDictionary] $fakeBoundParameters) {
        $results = [List[CompletionResult]]::new(<# capacity: #> 4)
        foreach ($name in $this::s_encodings) {
            if ($name -notlike "$wordToComplete*") {
                continue
            }

            $results.Add(
                [CompletionResult]::new(
                    <# completionText: #> $name,
                    <# listItemText:   #> $name,
                    <# resultType:     #> [CompletionResultType]::ParameterValue,
                    <# toolTip:        #> $name))
        }

        return $results.ToArray()
    }
}

class EncodingArgumentConverterAttribute : ArgumentTransformationAttribute {
    [object] Transform([EngineIntrinsics] $engineIntrinsics, [object] $inputData) {
        if ($null -eq $inputData) {
            return $null
        }

        if ($inputData -is [Encoding]) {
            return $inputData
        }

        $convertedValue = default([Encoding])
        if ([LanguagePrimitives]::TryConvertTo($inputData, [Encoding], [ref] $convertedValue)) {
            return $convertedValue
        }

        if ($inputData -isnot [string]) {
            $inputData = $inputData -as [string]
            if ([string]::IsNullOrEmpty($inputData)) {
                return $null
            }
        }

        switch ($inputData) {
            ASCII { return [Encoding]::ASCII }
            BigEndianUnicode { return [Encoding]::BigEndianUnicode }
            'Default' { return [Encoding]::Default }
            Unicode { return [Encoding]::Unicode }
            UTF32 { return [Encoding]::UTF32 }
            UTF7 { return [Encoding]::UTF7 }
            UTF8 { return [Encoding]::UTF8 }
        }

        return [Encoding]::GetEncoding($inputData)
    }
}
'@
