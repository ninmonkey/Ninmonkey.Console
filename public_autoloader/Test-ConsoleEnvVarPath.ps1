using namespace System.Management.Automation
$script:publicToExport.function += @('Test-ConsoleEnvVarPath')
$script:publicToExport.alias += @('Test-EnvVar')
# $script:publicToExport.alias += @('Find-Exception')

function Test-ConsoleEnvVarPath {
    <#
    .description
        Check if a path already exists or not
    .example

    .outputs
        [Boolean]

    .notes
        future
        future: -Strict param, warns when path already exists in the target

        future: strip trailing backslash before comparing?

    see:
        [io.path]::PathSeparator
        [io.path]::DirectorySeparatorChar
    #>
    [Alias('Test-EnvVar')]
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType('bool')]
    param (
        # Target Env Var
        [ValidateSet('Path', 'PSModulePath')]
        [Parameter(Mandatory, Position = 0)]
        [Alias('Target', 'Name')]
        [string]$EnvironmentVariableName,

        # Path or value to add
        [Alias('Value')]
        [Parameter(Mandatory, Position = 1)]
        [string]$Path
    )
    process {
        # ignore duplicates?
        $ExistingList = (Get-Item "env:\$EnvironmentVariableName").Value -split ([io.path]::PathSeparator)
        $ExistingList | Join-String -sep "`n" -SingleQuote -op 'ExistingPaths: ' | Write-Debug
        "'$EnvironmentVariableName', '$Path'" | Write-Debug
        if ($Path -in $ExistingList) {
            $true
            return
        }

        $false
        return
    }
}
