# Import-Module Ninmonkey.Console -Force

# init
$PSDefaultParameterValues['Write-ConsoleLabel:Separator'] = "`n"
$l = [list[object]]::new()
$l.Add( @{'a' = 2 } )
$l.Add( 'sts' )
$l.Add( 'sts'.gettype() )

H1 '$l.GetType().Name'

h1 '$l | %{ $_.GetType().Name }'
$l | ForEach-Object { $_.GetType().Name }

h1 '$l.GetType().Name'
$l.GetType().Name
(, $l).GetType().Name

hr
(, $l).GetType().Name | Label '.GetType().Name'
(, $l) | typeof | Label '(,$l)'
, (, $l) | typeof | Label ',(,$l)'

hr
H1 '$l | typeof'
$l | TypeOf

H1 ',$l | typeof'
, $l | TypeOf




# cleanup
$PSDefaultParameterValues.Remove('Write-ConsoleLabel:Separator')