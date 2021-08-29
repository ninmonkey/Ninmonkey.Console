using namespace System.Management.Automation
$script:publicToExport.function += @('Add-ConsoleEnvVarPath')
$script:publicToExport.alias += @('Add-EnvVar')
# $script:publicToExport.alias += @('Find-Exception')

function Add-ConsoleEnvVarPath {
    <#
    .description
        Modify $Env:Path with sanity checks, and prevent duplicates.
    .example
        # add to front
        Add-EnvVarPath 'C:\jake\github\powershell' -AddToFront

        # add to end
        Add-EnvVarPath 'C:\jake\github\powershell' -Verbose -Debug

        # Force adding even if not existing and even if if invalid path
        Add-EnvVarPath 'foo' -Force
    .notes
        future: -Strict param, warns when path already exists in the target

    see:
        [io.path]::PathSeparator
        [io.path]::DirectorySeparatorChar
    #>
    [Alias('Add-EnvVar')]
    [CmdletBinding(PositionalBinding = $false)]
    param (

        # Target Env Var
        [ValidateSet('Path', 'PSModulePath')]
        [Parameter(Mandatory, Position = 0)]
        [Alias('Target', 'Name')]
        [string]$EnvironmentVariableName,

        # Path or value to add
        [Alias('Value')]
        [Parameter(Mandatory, Position = 1)]
        [string]$Path,

        [Alias('Prepend')]
        [Parameter(HelpMessage = 'prepend or append value?')]
        [switch]$AddToFront,

        # 'Add without sanity checks. Always write regardless if the path already exists or not
        [Alias('AlwaysAdd')]
        [Parameter()][switch]$Force

    )
    process {

        [bool]$AlreadyExists = $false
        $AlreadyExists = Test-ConsoleEnvVarPath -Name $EnvironmentVariableName -Path $Path
        if ($AlreadyExists) {
            # And not force?
            Write-Warning "'$Path' already exists in '$EnvironmentVariableName'"
            return
        }

        # ignore duplicates?
        # $ExistingList = (Get-Item "env:\$EnvironmentVariableName") -split ([io.path]::PathSeparator)
        # if ($ExistingList -contains $Path) {
        #     $AlreadyExists = $true
        #     Write-Warning "'$Path' already exists in '$EnvironmentVariableName'"
        #     return
        # }

        <#


    # FileNotFoundException which one?
    # DirectoryNotFoundException
    #>
        # if (!(Test-Path Path -ea Continue)) {
        if (!(Test-Path $Path)) {
            Write-Warning "Invalid Path: $path"
            if (! $Force ) {
                $exception = [IO.FileNotFoundException]::new(
                    <# message : #> 'Filepath Does not currently exist',
                    <# fileName: #> $Path
                )
                $errorRecord = [ErrorRecord]::new(
                    <# exception    : #> $exception,
                    <# errorId      : #> 'MissingTarget',
                    <# errorCategory: #> [ErrorCategory]::InvalidArgument,
                    <# targetObject : #> $null)

                $PSCmdlet.WriteError( <# errorRecord: #> $errorRecord )
                return
            }
        }

        Write-Verbose "Adding: '$Path' to '$EnvironmentVariableName'"
        if (! $AddToFront ) {
            $Env:Path = $Path, $Env:Path -join ([io.path]::PathSeparator)
        }
        else {
            $Env:Path = $Env:Path, $Path -join ([io.path]::PathSeparator)
        }
        $Env:Path | Join-String -op 'Final Env Path'
    }

}
