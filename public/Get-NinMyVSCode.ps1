function Get-MyVSCode {
    <#
    .synopsis
        a global state to switch between code/codei and other data directories
    .description
       This isn't a VSCode wrapper, that's "Invoke-VsCode"

    .notes
        future:
        - [ ] save or autocomplete '--user-data-dir'
        - [ ] future: use env an env var
    .example
          .
    .link
        Invoke-VSCode
    .link
        Out-VSCode
    .outputs
          [string | None]

    #>
    [CmdletBinding(PositionalBinding = $false)]
    param(
        # [Parameter(Mandatory, Position = 0)]
        # [string]$Name
    )

    # $Env:__ninVsCode = 'code-insiders'
    $DefaultBin = 'code-insiders'
    $Strict_AlwaysReturnBin = $false
    $Strict_Exists = $false

    $envVarCode = $Env:__ninVsCode

    if ($envVarCode) {
        Write-Debug 'raw string from env var'
        $envVarCode
        return
    }



    # $selectedBin = 'code-insiders'
    # $selectedBin = 'code'

    Write-Debug "Strict_AlwaysReturnBin?: $Strict_AlwaysReturnBin"
    if ($Strict_AlwaysReturnBin) {
        $FinalBin = @(
            Get-NativeCommand -ea ignore 'code'
            Get-NativeCommand -ea ignore 'code-insiders'
        ) | Select-Object -First 1
        if ($FinalBin) {
            $FinalBin
            return
        }
        Write-Error 'Did not find "code[-insiders]"'
    }

    if ($Env:__ninVsCode) {
        $finalBin = Get-NativeCommand $Env:__ninVsCode -ea ignore
        $FinalBin ??= $defaultBin
    }
    $finalBin ??=

    if (! $FinalBin) {
        Write-Error 'ShouldNeverReachException:'
        $finalBin = $defaultBin
    }


}
