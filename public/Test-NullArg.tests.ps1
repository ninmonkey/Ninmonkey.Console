BeforeAll {
    Import-Module Ninmonkey.Console -Force
}
# $sc = {
$sample = @(
    40
    'a'
    @(),
    , @(),
    'aa'
    $null
    (, $null)
    ''
    '  '
    10, '', ' ', 0, $null, "`u{0}"
)
# }

$sample | ForEach-Object {
    $cur = $_
    # $cuR ??= '$null'
    h1 'step'
    $cur | Format-Typename -WithBrackets | Write-Color pink | str prefix 'item: '
    # $cur | Join-String -DoubleQuote | str prefix 'value: '
    Test-NullArg -InputObject $cur


}


return

# | Test-NullArg | Format-Table

$sc | iterProp | Sort-Object MemberType, Name
| Format-List Name, Value, TypeNameOfValue, ReflectionInfo

h1 'part1'
$scNew = $sc | iterProp | Sort-Object MemberType, Name
| ForEach-Object {
    # ㏒ℹℹ️
    $_ | Add-Member -NotePropertyName 'sTypeNameOfValue' -NotePropertyValue $($_ | Format-Typename -WithBrackets) -PassThru
    # $_.sTypeNameOfValue = $_ | Format-TypeName
} | s Name, Value, sTypeNameOfValue

h1 'part3'
#| Format-List Name, Value, sTypeNameOfValue, TypeNameOfValue, ReflectionInfo

hr
$scNew
| s #-ExcludeProperty 'TypeNameOfValue' *
| s Name, Value, sTypeNameOfValue, ReflectionInfo
# | s Value, sTypeNameOfValue, ReflectionInfo
# $scNew  | s Name, Value, sTypeNameOfValue
| Format-List *


h1 'part2'
$scNew = $sc | iterProp | Sort-Object MemberType, Name
| ForEach-Object {
    # ㏒ℹℹ️
    $_ | Add-Member -NotePropertyName 'sTypeNameOfValue' -NotePropertyValue $($_ | Format-Typename -WithBrackets) -PassThru

    '{0}{1}
{2}
' -f @(
        $_.sTypeNameOfValue | Write-Color gray80
        $_.Name
        $_.value
    )
    # $_.sTypeNameOfValue = $_ | Format-TypeName
} #| s Name, Value, sTypeNameOfValue
