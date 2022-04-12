# Ninmonkey.Console

Tools for a better console experience

- [Ninmonkey.Console](#ninmonkeyconsole)
- [Useful Commands](#useful-commands)
  - [`Fzf` : Select Values like a simplified `Out-GridView -PassThru`](#fzf--select-values-like-a-simplified-out-gridview--passthru)
  - [Text output](#text-output)
  - [Conversions](#conversions)
- [Custom Verbs](#custom-verbs)
- [Frequently used](#frequently-used)
- [Console Encoding](#console-encoding)
- [AppxPackages : Windows Apps](#appxpackages--windows-apps)
- [Types](#types)
  - [Format-TypeName](#format-typename)
  - [Format-GenericTypeName](#format-generictypename)
  - [Test-NullArg](#test-nullarg)
- [See More](#see-more)
  - [libs](#libs)
  - [vexx32.github.io : Autocomplete and more](#vexx32githubio--autocomplete-and-more)
  - [Docs](#docs)


# Useful Commands

| Name           | Description                                 |
| -------------- | ------------------------------------------- |
| `Hex`          | `ConvertTo-HexString`                       |
| `Bits`         | `ConvertTo-BitString`                       |
| `Base64`       | .                                           |
| `Get-EnumInfo` | .                                           |
| `Out-Fzf`      | .                                           |
| `Out-Code`     | .                                           |
| `Goto`         | `cd` to directory, works on non-directories |
| `Here`         | Open filemanager                            |

## `Fzf` : Select Values like a simplified `Out-GridView -PassThru`

```powershell
🐒> Get-ChildItem $Env:APPDATA -Directory | Out-Fzf | Format-RelativePath $Env:APPDATA
.\Code
.\Code - Insiders
```
```powershell
🐒> $Fzf
C:\Users\monkey\AppData\Roaming\Code
C:\Users\monkey\AppData\Roaming\Code - Insiders
# $Fzf was set because it defaults to:
$PSDefaultParameterValues['Out-Fzf:OutVariable'] = 'Fzf'
```

## Text output
| Name    | Description                  |
| ------- | ---------------------------- |
| `Label` | Colored `Label: Value` pairs |
| `H1`    | Heading text                 |
| `Br`    | Add newlines                 |
| `Hr`    | Horizontal Rule with padding |


## Conversions

```powershell
🐒> $numbers = 0, 127, 0xffef
  >> $numbers | Hex
0x0
0x7f
0xffef

🐒> $numbers | Bits
0000.0000
0111.1111
1111.1111 1110.1111

🐒> '0x34' | Number # returned type [Int32]

🐒> $bytes | Base64
```

# Custom Verbs

| Name                  | Description                                                                                                                                                                                                                                                                                                                        |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Ensure->`            | ensure condition is true, else make it so, <br>like: `Ensure-FileExists`, `Ensure-CurrentDirIs`, etc.<br>The intent is non-fatal asserts on a state, which are silently resolved -- if needed                                                                                                                                      |
| `Resolve->`           | ConvertType to another type -- if needed.<Br>Like: `Resolve-TypeInfo`, ..<br/>`Resolve->FileInfo` attempts to return a `Get-Item`. If it fails, return the original string, instead of errors or nothing. <br>`Resolve->` Is similar to `Ensure->`, the difference is `Resolve->` returns objects . Ensure is about a valid state. |
| `To->`  and  `From->` | Sugar for `ConvertTo-Type` and `ConvertFrom-Type` / load from                                                                                                                                                                                                                                                                      |
| `Fmt->`               | Custom Formatting of objects and strings depending on the command<br>Built to chain off of one another, unlike `Format-*` functions                                                                                                                                                                                                |

# Frequently used

```ps1
# Jump to modules
🐒> Get-Module PSKoans | Goto 
    pwd

C:\Users\monkey\Documents\PowerShell\Modules\PSKoans\0.67.1
```

# Console Encoding

```powershell
🐒> Get-ConsoleEncoding

Name                      Encoding        CodePage isSingleByte
----                      --------        -------- ------------
OutputEncoding            Unicode (UTF-8)    65001        False
[console]::InputEncoding  Unicode (UTF-8)    65001        False
[console]::OutputEncoding Unicode (UTF-8)    65001        False
```

# AppxPackages : Windows Apps

Package names are not always descriptive. Sometimes nothing in the fields `Name`, `PackageName` or `FamilyName` are useful.

This example has the package name `Dayton` even though the game is named `State of Decay 2`
```powershell
🐒> Get-AppXPackage *state*decay*
# nothing found

🐒> $results = Get-NinAppXPackage 'state.*decay' -PassThru
🐒> $results | Format-List
```
```
Regex   : state.*decay
App     : Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe
ExeList : {C:\Program Files\WindowsApps\Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe\StateOfDecay2.exe, C:\Program Files\WindowsApps\Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe\StateOfDecay2\Binaries\Win64\StateOfDecay2-Win64-Shipping.exe}
```
```powershell
🐒> Get-NinAppXPackage 'state.*decay'
```
```
Name              : Microsoft.Dayton
Publisher         : CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US
Architecture      : X64
ResourceId        :
Version           : 2.408.280.0
PackageFullName   : Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe
InstallLocation   : C:\Program Files\WindowsApps\Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe
IsFramework       : False
PackageFamilyName : Microsoft.Dayton_8wekyb3d8bbwe
PublisherId       : 8wekyb3d8bbwe
IsResourcePackage : False
IsBundle          : False
IsDevelopmentMode : False
NonRemovable      : False
Dependencies      : {Microsoft.VCLibs.140.00.UWPDesktop_14.0.29231.0_x64__8wekyb3d8bbwe}
IsPartiallyStaged : False
SignatureKind     : Store
Status            : Ok

Regex   : state.*decay
App     : Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe
ExeList : {C:\Program Files\WindowsApps\Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe\StateOfDecay2.exe, C:\Program Files\WindowsApps\Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe\StateOfDecay2\Binaries\Win64\StateOfDecay2-Win64-Shipping.exe}

Regex        App
-----        ---
state.*decay Microsoft.Dayton_2.408.280.0_x64__8wekyb3d8bbwe
```

# Types


## Format-TypeName

```powershell
🐒> ls . | foreach-object{ $_.pstypenames } | sort -Unique
System.IO.DirectoryInfo
System.IO.FileInfo
System.IO.FileSystemInfo
System.MarshalByRefObject
System.Object

🐒>  ls . | foreach-object{ $_.pstypenames } | sort -Unique | Format-TypeName
[IO.DirectoryInfo]
[IO.FileInfo]
[IO.FileSystemInfo]
[MarshalByRefObject]
[Object]
```


## Format-GenericTypeName

```powershell
🐒> $items = [list[string]]::new()
  $items.GetType().FullName

System.Collections.Generic.List`1[[System.String, System.Private.CoreLib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]

🐒> $items.GetType() | Format-TypeName

List`1[[String]]
```


## Test-NullArg


```powershell

🐒> 10, '', " ", $null, "`u{0}" | Test-NullArg | Format-Table

Value Type   IsNull IsNullOrWhiteSpace IsNullOrEmpty AsString ToString CastString TestId IsNullCodepoint
----- ----   ------ ------------------ ------------- -------- -------- ---------- ------ ---------------
   10 Int32   False              False         False '10'     '10'     '10'            0           False
      String  False               True          True ''       ''       ''              1            True
      String  False               True         False ' '      ' '      ' '             2           False
    ␀ [Null]   True               True          True ''       '␀'      ''              3           False
    ␀ String  False              False         False '␀'      '␀'      '␀'             4            True
```

# See More

## libs

- [ClassExplorer](https://github.com/seeminglyscience) by SeeminglyScience/ClassExplorer

## vexx32.github.io : Autocomplete and more

- [Creating Dynamic Sets for ValidateSet](https://vexx32.github.io/2018/11/29/Dynamic-ValidateSet/)
- [Working With Argument Transformations in PowerShell](https://vexx32.github.io/2018/12/13/Working-Argument-Transformations/)
- [Working with PowerShell's -replace Operator](https://vexx32.github.io/2019/03/20/PowerShell-Replace-Operator/)
- [ScriptBlocks and GetNewClosure\(\)](https://vexx32.github.io/2020/05/30/Scriptblock-GetNewClosure/)
- [Searching the PowerShell Abstract Syntax Tree](https://vexx32.github.io/2018/12/20/Searching-PowerShell-Abstract-Syntax-Tree/)
- [Implementing-ShouldProcess](https://vexx32.github.io/2018/11/22/Implementing-ShouldProcess/)
- [Invoke a PowerShell Module Command in the Global Scope](Invoke a PowerShell Module Command in the Global Scope)
  - > & (Get-Module 'Pester') { Get-Command -Module Pester }

## Docs
- Autocompletion [enum CompletionResultType ](https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.completionresulttype?view=powershellsdk-7.0.0#System_Management_Automation_CompletionResultType)
- [IArgumentCompleter.CompleteArgument\(String, String, String, CommandAst, IDictionary\) Method](https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.iargumentcompleter.completeargument?view=powershellsdk-7.0.0)