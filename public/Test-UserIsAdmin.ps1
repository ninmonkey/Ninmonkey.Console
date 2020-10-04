function Test-UserIsAdmin {
    <#
    .description
        test if the current user in role: [Security.Principal.WindowsBuiltInRole]::Administrator
    #>
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}