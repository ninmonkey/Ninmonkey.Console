# Ninmonkey.Console

Tools for a better console experience

- [Ninmonkey.Console](#ninmonkeyconsole)
  - [Console Encoding](#console-encoding)
  - [AppxPackages : Windows Apps](#appxpackages--windows-apps)
  - [Types](#types)
    - [Format-TypeName](#format-typename)
    - [Format-GenericTypeName](#format-generictypename)
    - [Test-NullArg](#test-nullarg)


## Console Encoding

```powershell
🐒> Get-ConsoleEncoding      

Name                      Encoding        CodePage isSingleByte
----                      --------        -------- ------------
OutputEncoding            Unicode (UTF-8)    65001        False
[console]::InputEncoding  Unicode (UTF-8)    65001        False
[console]::OutputEncoding Unicode (UTF-8)    65001        False
```

## AppxPackages : Windows Apps

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

## Types


### Format-TypeName

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


### Format-GenericTypeName

```powershell
🐒> $items = [list[string]]::new()
  $items.GetType().FullName

System.Collections.Generic.List`1[[System.String, System.Private.CoreLib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]

🐒> $items.GetType() | Format-TypeName

List`1[[String]]
```


### Test-NullArg


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
