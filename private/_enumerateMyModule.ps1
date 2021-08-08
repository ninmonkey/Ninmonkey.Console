function _enumerateMyModule {
    <#
    .synopsis
        internal function, when I need to 'guess' at my module names.
    .description
        super inefficient, but easily catches all cases
    .notes
        todo: at leeast cache the get-module call
        using
            'Test-AnyTrue'
    .outputs
        [string[]] of Module names
    #>
    [cmdletbinding()]
    param()
    @(
        'Dev.Nin'
        '*ninmonkey*'
        Get-Module * | Where-Object Author -Match 'jake\s*bolton' | ForEach-Object Name
        Get-Module * | Where-Object CompanyName -Match 'jake\s*bolton' | ForEach-Object Name
        Get-Module * | Where-Object CompanyName -Match 'corval.*group' | ForEach-Object Name
        Get-Module * | Where-Object Copyright -Match 'jake\s*bolton' | ForEach-Object Name
        Get-Module * | Where-Object Copyright -Match 'corval.*group' | ForEach-Object Name
        Get-Module * | Where-Object Copyright -Match '.*ninmonkey.*' | ForEach-Object Name
        'Ninmonkey.Console'
        'Ninmonkey.Factorio'
        'Ninmonkey.Powershell'
        'Ninmonkey.Power*bi'
    ) | Sort-Object -Unique | Get-Module
    | ForEach-Object Name
    | Sort-Object -Unique
}
