Import-Module ninmonkey.console -Force 3>$null

if (-not (Get-Command 'h1' -ea Ignore)) {
    function h9 {
        param( [string]$Text )
        "`n`n ## $Text `n`n"
    }

}

function _testIt {
    param(
        # Test subject
        [ValidateNotNull()][Parameter()]$Obj,
        # Label for summary
        [string]$Label
    )

    if ($Null -eq $Obj) {
        throw 'Obj was null, requires value.'
    }
    $ContentWasErr = $false
    $MaybeContent = try {
        Get-Content $Obj -ea stop
    } catch {
        $ContentWasErr = $true
        $_.Exception.Message
    }

    # $maybeContent =
    $dbg = [ordered]@{
        'Label'           = $Label
        'Exists?'         = Test-Path $Obj
        'Name'            = $Obj.Name ?? '<null>'
        'FullName'        = $Obj.FullName ?? '<null>'
        'Types?'          = $Obj.PStypeNames | Csv2
        'Length'          = $Obj.Length ?? '<null>'
        'Content'         = $MaybeContent ?? '<null>'
        'ContentWasError' = $ContentWasErr
    }
    return [pscustomobject]$dbg
}

$error.clear()

$validPath = Get-ChildItem -Path '~' -File | Select-Object -First 1

H1 'declarations'
# testing out severasl providers, some with full PSPath
$existing = Resolve-ItemInfo $ValidPath
$notExisting = Resolve-ItemInfo 'C:\nin_temp\does-not-exist.txt'
$notExistingSilent = Resolve-ItemInfo 'C:\nin_temp\does-not-exist2.txt' -eaIgnore
$red = Resolve-ItemInfo 'fg:\red'
$greenLong = Resolve-ItemInfo 'RgbColor::Foreground:\green'
$envVar = Resolve-ItemInfo 'Env:\PSModulePath'
$RegKey = Resolve-ItemInfo 'HKLM:\SOFTWARE\2cb19db4-ef7e-57de-a035-c8b3afe9f334'
$VarLong = Resolve-ItemInfo 'Microsoft.PowerShell.Core\Variable::validpath'
$var = Resolve-ItemInfo 'Variable::validpath'

H1 'before tests'
$error.count
| Label '$Error.count'

$Tests = @(
    _TestIt $existing 'Existing'
    _TestIt $notExisting 'NotExisting'
    _TestIt $notExistingSilent 'NotExistingSilent'
    _TestIt $red 'fg:\red'
    _TestIt $greenLong 'RgbColor::Foreground:\green'
    _TestIt $envVar 'Env:\PSModulePath'
    _TestIt $RegKey 'HKLM:\SOFTWARE\2cb19db4-ef7e-57de-a035-c8b3afe9f334'
    _TestIt $VarLong 'Microsoft.PowerShell.Core\Variable::validpath'
    _TestIt $Var 'Variable::validpath'
)

Hr

H1 'After tests'
$error.count
| Label '$Error.count'
