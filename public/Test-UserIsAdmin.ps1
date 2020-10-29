function Test-UserIsAdmin {
    <#
    .synopsis
        test if the current user in role: [Security.Principal.WindowsBuiltInRole]::Administrator
    .example
        PS>  Test-UserIsAdmin
    #>
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}