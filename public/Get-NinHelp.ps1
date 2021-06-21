function Get-NinHelp {
    # placeholder
    $ModuleList = @{
        'FavModules' = 'ClassExplorer', 'EditorServicesCommandSuite', 'Pansies', 'PowerShellEditorServices.Commands', 'PowerShellEditorServices.VSCode', 'PSReadLine'

        'MyModules' = @(
            'Dev.Nin'
            'Ninmonkey.Console'
            'Ninmonkey.Powershell'
            'Powershell.Cv'
            '*.cv'
            'cv.*'
            '*.Jake'
            'Jake.*'
        )
    }
    Get-Command -Module $ModuleList.MyModules

    write-warning 'nyi. Next will include FunctionInfo query'
}
