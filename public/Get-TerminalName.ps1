function Get-TerminalName {
    <#
    .description
        detect terminal type or user's config to override defaults
    .example

        PS> GezGet-TerminalName

            Name                           Value
            ----                           -----
            IsVSCode                       False
            IsWindowsTerminal              True
            ParentName                     WindowsTerminal.exe
    .notes

        todo:
            - [ ] optional read user's profile to override guess


        powershell equivalent for "feature testing verses user agent sniffing"
        for (process.parent property) on  'WindowsPowershell' vs 'Powershell'

        thread: <https://discordapp.com/channels/180528040881815552/447476117629304853/763122791112376340>
        1]
            $proc.psobject.Properties['Parent']
        2]
            if ($psSelf.PSObject.Properties.Name -contains 'Parent') {
        3]
            # if ($PSVersionTable.PSVersion.Major -lt 6 ) {
    #>

    $psSelf = Get-Process -Id $pid

    if ($psSelf.PSObject.Properties.Name -contains 'Parent') {
        $ParentName = $psSelf.Parent.Name
    } else {
        # fallback behaviour
        $psCimSelf = (Get-CimInstance -Class Win32_Process -Filter "ProcessId = $Pid")
        $parentPid = $psCimSelf.ParentProcessId
        $psCimParent = (Get-CimInstance -Class Win32_Process -Filter "ProcessId = $parentPid")
        $ParentName = $psCimParent.ProcessName
    }

    $results = @{
        IsVSCode          = $ParentName -match 'Code'
        IsWindowsTerminal = $ParentName -match 'WindowsTerminal'
        ParentName        = $ParentName
    }
    $results
}
