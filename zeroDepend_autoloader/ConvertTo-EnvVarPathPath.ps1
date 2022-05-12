#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'ConvertTo-EnvVarPath'
        'ConvertTo-ExpandedEnvVarPath'
    )
    $publicToExport.alias += @(
        'toEnvPath' # 'ConvertTo-EnvVarPath'
        'fromEnvPath' # 'ConvertTo-ExpandedEnvVarPath'
    )
}
function ConvertTo-EnvVarPath {
    <#
    .synopsis
        Convert full paths to relative paths using environment variables
    .example
        PS> ConvertTo-EnvVarPath 'C:\Users\cppmo_000\AppData\Local'
        $Env:LocalAppData
    .example
        PS> ConvertTo-EnvVarPath -AutoClip

        PS> gi env:userProfile | ConvertTo-EnvVarPath  | ConvertFrom-EnvVarPath
    .link
        ConvertTo-EnvVarPath
    .link
        ConvertTo-ExpandedEnvVarPath
    #>
    [Alias('toEnvPath')]
    param(
        # Path to transform
        [Parameter(ValueFromPipeline)]
        [string]$Path,

        # Read path from the clipboard, then save the transformed valueconvert, set clipboard

        [Alias('Clip')]
        [switch]$AutoClip
    )
    $accum = $path
    if ($AutoClip) {
        $accum = Get-Clipboard
    }
    if ( [string]::IsNullOrWhiteSpace($Accum)) {
        Write-Error -ea stop -Category InvalidArgument -Message 'Path was blank' -ErrorId 'toEnvVar.paramIsBlank'
    }
    $accum = $accum -replace ([Regex]::escape("$Env:AppData")), '$Env:AppData'
    $accum = $accum -replace ([Regex]::escape("$Env:LocalAppData")), '$Env:LocalAppData'
    $accum = $accum -replace ([Regex]::escape("$Env:UserProfile")), '$Env:UserProfile'
    $accum = $accum -replace ([Regex]::escape("$Env:AllUsersProfile")), '$Env:AllUsersProfile'

    if ($AutoClip) {
        $accum | Set-Clipboard
        Write-Information "clip -> $Accum"
        return
    }
    return $accum
}
function ConvertTo-ExpandedEnvVarPath {
    <#
    .synopsis
        Convert env var paths to a path
    .example
        PS> ConvertTo-ExpandedEnvVarPath $Env:LocalAppData
         'C:\Users\cppmo_000\AppData\Local'

    .example
        PS> ConvertTo-EnvVarPath -AutoClip
    .link
        ConvertTo-EnvVarPath
    .link
        ConvertTo-ExpandedEnvVarPath

    #>
    [Alias('fromEnvPath')]
    param(
        # Path to transform
        [Parameter(ValueFromPipeline)]
        [string]$Path,

        # Read path from the clipboard, then save the transformed valueconvert, set clipboard
        [Alias('Clip')]
        [switch]$AutoClip
    )
    $accum = $path
    if ($AutoClip) {
        $accum = Get-Clipboard
    }
    if ( [string]::IsNullOrWhiteSpace($Accum)) {
        Write-Error -ea stop -Category InvalidArgument -Message 'Path was blank' -ErrorId 'fromEnvVar.paramIsBlank'
    }

    $accum = $ExecutionContext.InvokeCommand.ExpandString( $Accum )
    if ($AutoClip) {
        $accum | Set-Clipboard
        Write-Information "clip -> $Accum"
        return
    }
    return $accum
}
