if (-not (Get-Command 'h1' -ea Ignore)) {
    function h9 {
        param( [string]$Text )
        "`n`n ## $Text `n`n"
    }

}
$Error.clear()


function _testIt {
    param(
        [ValidateNotNull()][Parameter()]$Obj, [string]$Label
    )

    if ($Null -eq $Obj) {
        Write-Error 'Obj was null, requires value.'
        return
    }
    $dbg = [ordered]@{
        'Label'    = $Label
        'Exists?'  = Test-Path $Obj
        'Name'     = $Obj.Name ?? '<null>'
        'FullName' = $Obj.FullName ?? '<null>'
        'Types?'   = $Obj.PStypeNames | Csv2
        'Length'   = $Obj.Length ?? '<null>'
        'Content'  = try {
            Get-Content $Obj -ea stop
        } catch {
            $_.Exception.Message
        }
    }
    return [pscustomobject]$dbg
}



$validPath = Get-ChildItem -Path '~' -File | Select-Object -First 1

$existing = Resolve-FileInfo $ValidPath
$existing.Length
$notExisting = Resolve-FileInfo 'C:\nin_temp\does-not-exist.txt'
$notExisting
$notExistingSilent = Resolve-FileInfo 'C:\nin_temp\does-not-exist.txt' -ea Ignore
$notExistingSilent
$red = Resolve-FileInfo 'fg:\red'
$red
$greenLong = Resolve-FileInfo 'RgbColor::Foreground:\green'
$greenLong

# Test-Path -Path $existing, $notExisting
$Tests = @(
    _TestIt $existing 'Existing'
    _TestIt $notExisting 'NotExisting'
    _TestIt $notExistingSilent 'NotExistingSilent'

    H1 'Color Fg:\red'
    _testIt 'Foreground:\red' 'Fg'
)

Hr



return
# H1 'notExisting'
# H1 'c'
# H1 'd'


# if ($false) {
#     'text' | Set-Content $notExisting ; Get-Content $notExisting;
#     'text' | Set-Content $notExisting ; Get-Item $notExisting
#     Remove-Item $notExisting
#     Remove-Item $notExisting
#     $notExisting
#     Get-Item $notExisting
#     Get-History
#     Get-History | ReverseIt
# }