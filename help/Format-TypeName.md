# Format-TypeName

## Make Generic types readable

```powershell
# Often types are too specific by including assembly information
PS> $params = (Get-Command Get-ChildItem).Parameters
    $params.GetType()

Name         FullName
----         --------
Dictionary`2 System.Collections.Generic.Dictionary`2[[System.String, System.Private.CoreLib, Version=5.0.0.0,
Culture=neutral, PublicKeyToken=7cec85d7bea7798e],[System.Management.Automation.ParameterMetadata,
System.Management.Automation, Version=7.1.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]]

# Simplify Generic argument types using type names
PS> $params | Format-TypeName

Dictionary`2[System.String, System.Management.Automation.ParameterMetadata]
```

## Examples

```powershell
🐒> [list[int]]


Name   FullName                                                                                                                                     Base
----   --------                                                                                                                                     ----
List`1 System.Collections.Generic.List`1[[System.Int32, System.Private.CoreLib, Version=5.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]] System.Object


🐒> [list[int]] | format-typename

List`1[Int32]

🐒> [list[int]] | % gettype | % fullname

System.RuntimeType

🐒> [list[int]] | % gettypeinfo | % fullname

System.Collections.Generic.List`1[[System.Int32, System.Private.CoreLib, Version=5.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]

🐒> [list[int]] | % gettypeinfo | % fullname | format-typename

List`1[[System.Int32, System.Private.CoreLib, Version=5.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]
```