# Ninmonkey.Console

Tools for a better console experience

- [Ninmonkey.Console](#ninmonkeyconsole)
  - [Types](#types)
    - [Test-NullArg](#test-nullarg)


## Types
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