#Requires -Version 7.1

function Get-NinMyVSCode {
    <#
    .synopsis
        a global state to switch between code/codei and other data directories
    .description
       This isn't a VSCode wrapper, that's "Invoke-VsCode"

    .notes
        replaced by Dev.Nin/Code-Venv

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
    Write-Error 'replaced by Dev.Nin/Code-Venv'

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
    # method 1, no validation
    $finalBin = $Env:__ninVsCode
    $finalBin ??= Get-NativeCommand 'code-insiders' -ea ignore
    $finalBin ??= Get-NativeCommand 'code' -ea ignore
    $finalBin ??= $DefaultBin
    $FinalBin = $finalBin | Get-Command 'code-insiders' | Get-Item
    # Temporarily forcing get-item because it invoked easier

    if ($Strict_MustExist) {
        $finalBin | Get-NativeCommand -ea stop
        # | Select -first 1 # does that help or not?
    }
    $finalBin
    | Get-Item | Select-Object -First 1




    return
    if ($false -and 'was messing with alternate structure') {
        # alternate method, plus requires validate.
        $cmdSplat = @{
            ErrorAction = 'ignore'
        }
        if ($Strict_Exists) {
            $cmdSplat.ErrorAction = 'Stop'
        }
        $finalBin = @(
            $Env:__ninVsCode
            'code-insiders'
            'code'
        ) | Get-NativeCommand @cmdSplat


        $finalBin = @(
            $Env:__ninVsCode
            'code-insiders'
            'code'
        ) | Get-NativeCommand -ea ignore

        if ($Strict_MustExist) {
            $FinalBin | Get-NativeCommand -ea stop
            return
        }
        $finalBin
        | Select-Object -First 1




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

}
