Import-Module Ninmonkey.Console -Force #| Out-Null
# Some tests are visual, or not Pester worthy
# This file is a scratchboard

# H1 'quick test'
$ConfigTest = @{
    'tryCommand'                 = $True
    'PropertyList.Format.ps1xml' = $True
    'PropShortTypeName'          = $false
    'PropShortTypeName_Coerce'   = $false
    'LabelWithPropParam'         = $false
    'LabelFromPropAndPipeline'   = $false
    'MaxInput'                   = $false
    'NinCommand'                 = $false
    'Temp'                       = $false
    'CustomObject'               = $false
    'CustomObject2'              = $false
    'GetCommand'                 = $false
}
$ConfigTest | Format-HashTable -Title 'Config'

if ( $ConfigTest.'tryCommand' ) {
    Import-Module Ninmonkey.Console -Force -DisableNameChecking
    Resolve-CommandName 'ls'
    return
    # Get-CommandSummary Get-ChildItem
    # Get-CommandSummary 'Get-ConsoleEncoding', 'Write-ConsoleHeader'
    Get-CommandSummary 'Get-ChildItem', 'Write-ConsoleHeader'

    Get-Command -Module ClassExplorer, Ninmonkey.Console
    | Sort-Object Module, CommandType, Name
    | Format-Table CommandType, Name, Version, Description  -AutoSize -GroupBy Source
}
if ( $ConfigTest.'PropertyList.Format.ps1xml' ) {
    Get-PSReadLineOption | Prop
}

if ( $ConfigTest.'PropShortTypeName' ) {
    # Get-PSReadLineOption | Prop | Format-Table -AutoSize
    # Hr 3
    Get-PSReadLineOption | Prop | Format-Table -AutoSize *
    Hr 2
    Get-PSReadLineOption | Prop | Select-Object Type, Name
    H1 'compare'
    Get-PSReadLineOption | Prop | Format-Table -AutoSize Value, Type, TypeOfInstance, Name
}

if ( $ConfigTest.'PropShortTypeName_Coerce' ) {


    (Get-PSReadLineOption).AddToHistoryHandler.GetType() | Format-TypeName
    | Label 'Format-TypeName 1'

    (Get-PSReadLineOption).AddToHistoryHandler | Format-TypeName | Label 'Format-Typename 2'

    (Get-PSReadLineOption).AddToHistoryHandler | Format-TypeName | ForEach-Object { $_ -as 'type' } | Format-TypeName
    | Label 'Format-TypeName -> type -> FormatTypename'

    <#
        a simple..ToString() returns:

            System.Func`2[System.String,System.Object]

        or (Get-PSReadLineOption).AddToHistoryHandler.GetType().ToString() -as 'type' | Format-TypeName

            Func`2[String, Object]
        #>
}


if ( $ConfigTest.'LabelFromPropAndPipeline' ) {
    Write-Warning '-Property not fully implemented'
    'foo', 'bar' | Label 'string' -PropertyName Length
    Label 'string' 'value' -PropertyName Length

}
if ( $ConfigTest.'LabelFromPropAndPipeline' ) {
    Label 'greeting' 'woof' -Debug -Verbose -InformationAction continue

    $colors = Get-ChildItem fg:
    function randColor { $colors | Get-Random }
    'sdf' | Label 3 length
    0..4 | Label 'nums' -fg (randColor) -fg2 (randColor)
    0..4 | JoinStr | Label 'nums2' -fg orange -ea Break
}

if ( $ConfigTest.MaxInput ) {
    0..4 | ForEach-Object { [string]$_ }
    | Prop

    Hr
    0..4 | ForEach-Object { [string]$_ }
    | Prop -Limit 2

}
if ( $ConfigTest.NinCommand ) {
    Get-NinCommand
    _Format-Command
}


if ( $ConfigTest.Temp ) {
    # H1 'Prop output:'
    # Get-ChildItem . | Get-Unique -OnType | Select-Object -First 1 | Prop | Format-Table
    # (Get-Date) | Prop | Format-Table

    # Write-Warning 'bug:'


    <#
# is not returning properties on itself:
> @(34) | prop

> (34) | Prop | ExpectedToBe Blank

> @(34) | Prop | ExpectedToBe List

# Should be:
> $x.psobject.properties'
#>
}

if ( $ConfigTest.CustomObject ) {
    $catHash = @{'a' = 'cat'; age = 9; children = (0..4) }
    $catObj = [pscustomobject]$catHash

    H1 'Test1] Param'
    $gcm = Get-Command Select-Object
    $gcm.Parameters | Prop | Format-Table

    H1 'Test2] Basic Objects'
    $catHash | Prop | Format-Table
    $catObj | Prop | Format-Table
}

Hr

if ( $ConfigTest.CustomObject2 ) {

    $catHash = @{'a' = 'cat'; age = 9; children = (0..4) }
    $catObj = [pscustomobject]$catHash

    Label 'hash'
    $catHash | Prop # Get-ObjectProperty

    Label 'Obj'
    $catObj | Prop # Get-ObjectProperty
}
if ( $ConfigTest.GetCommand ) {
    $gcm = Get-Command Select-Object
    $gcm.Parameters | Prop | Format-List
    $gcm.Parameters | Prop | Format-Table
    $prop = $gcm.psobject.properties | Where-Object  Name -EQ Parameters # | % TypeNameOfValue
    $prop.TypeNameOfValue -as 'type' | Format-TypeName
}

# $ConfigTest | Format-HashTable -Title 'Config'
