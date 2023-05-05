## Version 0.2.21

### Functions with `-Options` Parameters

- When a Function's parameter is named `-Options`, it takes a hashtable to modify behavior
- Internally, functions always reference `-Options` as the hashtable `$Config`. This is to make it clear it's the merged settings
- `-Options` functions often have a few templates that autocomplete. 

Settings are merged like this:
```ps1
$Config = mergeHashtable -BaseHash $DefaultValues -OtherHash $Options

# ex:
$Config = mergeHashtable -BaseHash @{ Name = 'fred' ; Region = 'east' } -OtherHash @{ Id = 4 ; Region = 'North' }
```

### Faster import

- Some things were cleaned up a bit, and I disabled some debug JSON files from writing on load.
- If import is printing any text on load, you can increase speed a bit by redirecting all streams to `$null`. (This applies to all modules).
```ps1
# silently import
Import-Module ninmonkey.Console -wa Ignore *>$null
```

- `Import-Module CompletionPredictor` is optional. 

It's not the default because it has a pretty significant import cost relative most modules.
```ps1
# my default
nin.ImportPSReadLine MyDefault_HistListView
# if you don't care about the initial import time, try the CompletionPredictor
nin.ImportPSReadLine Using_Plugin
```

### `Format-UnorderedList` aliased as `UL` and `join.UL`

- No longer errors when pipping nulls and empty strings to `Format-UnorderedList` without errors
- added a new alias `join.UL` for less ambiguity / consistency with future commands. `UL` is still defined. 

![image](img/format-ul-completer.png)

### New Experimental commands `Eye` and `io`

- You can use `Eye` to get a quick view of something. 
- For filterable output, `Inspect-ObjectProperty` aliased as `io` returns objects

```ps1
eye (get-date)
eye (gi .)
```
- `io` inspects and views `psobject.properties`
- `Eye` also uses `ClassExplorer\Find-Member`
```ps1
$PSStyle | io -SortBy Reported
| ? Type  -notmatch 'string'
| Ft Reported, Name, Type, IsNull, Is*, Value -AutoSize
```

examples

```ps1

$t = gi .

h1 'find non-blank properties'
$t 
| io -SortBy Reported
| ? IsBlank -Not
| Ft Reported, Name, Type, IsNull, Is*, Value -AutoSize

h1 'find blank properties'
$t
| io -sortBy Type
| ? IsBlank
| Ft Reported, Name, Type, IsNull, Is*, Value -AutoSize

h1 'ignore any null properties'
$t
| io -sortBy Type
| ? -not IsNull
| Ft Reported, Name, Type, IsNull, Is*, Value -AutoSize
```

![image](https://user-images.githubusercontent.com/3892031/201253572-be9547ec-4587-4521-a66d-d75c8f445782.png)
![image](https://user-images.githubusercontent.com/3892031/201253858-8091eb77-9747-4646-b4d7-ed711e7e3d10.png)

### bugfix

- Auto reset the log from `Enable-NinHistoryHandler`, if it when size >= 5MB.
- (Even before) It shouldn't have ran unless you explicitly call `Enable-NinHistoryHandler` 
- changed the message to a warning, to prevent accidentally enabling it in a profile

See: [changes.md](docs/changes.md) for more


