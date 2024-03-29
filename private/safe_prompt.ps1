# temp, move to auto load, and, move to ZD directory
$tmpExport = @{
    Functions = @(
        'Enable-NinPrompt'
        'Invoke-NinPrompt'
    )
    Aliases   = @(

    )
}

# . (Get-Item -ea 'continue' 'C:\Users\cppmo_000\SkyDrive\Documents\2021\Powershell\My_Github\Ninmonkey.Console\prompt_block\prompt_blocks.ps1')

$script:___promptInfo = @{
    Current = '__prompt_noModuleLoaded'
    # '__safePrompt_blah'
    # '__prompt_noModuleLoaded'
    # '__prompt_usingColorExperiment_v2'
    # '__prompt_usingColorExperiment_v1'

}

function __safePrompt_blah {
    <#
    .synopsis
        zero dependency prompt, that includes errors
    .notes
        If function is declared locally, then $error must use global:
    .link
        __safePrompt_sorta
    #>
    param(
        # [switch]$Enable
    )
    # if ($Enable) {
    #     $global:prompt = $script:__safePrompt
    # }
    @(
        "`n", ($global:Error.count ?? 0),
        "`nPS> "
    ) -join ''
}
function __safePrompt_sorta {
    <#
    .synopsis
        slightly added depedencies but mostly not
    .link
        __safePrompt
    #>
    [cmdletbinding()]
    param(
        # [switch]$Enable
    )

    # Write-Warning 'not-imported: _fmt_FilepathWithoutUsernamePrefix'


    $colorPrefix = New-Text -fg gray50 'nin'

    $renderPath = Get-Location
    # | _fmt_FilepathWithoutUsernamePrefix -ReplaceWith $colorPrefix
    # | _fmt_FilepathForwardSlash

    $errorCount = $global:Error.count ?? 0
    # $errorString = ($global:Error.count ?? 0)
    $errorColor = switch ($errorCount) {
        { $_ -ge 1 -and $_ -lt 5 } {
            'orange' ; break
        }
        { $_ -ge 5 -and $_ -lt 12 } {
            'darkorange'; break
        }
        { $_ -gt 12 -and $_ -lt 20 } {
            'orangered'; break
        }
        { $_ -ge 20 } {
            'red'; break
        }
        0 {
            'gray50'
        }
        default {
            'magenta'
        }
    }
    Write-Debug "Count: '$ErrorColor', '$errorCount'"
    # $renderError = $errorColor, $errorCount -join ''
    $renderError = New-Text -fg $errorColor $errorCount
    $renderError | Write-Debug

    @(
        "`n"
        "`n"
        # ($global:Error.count ?? 0)
        $renderPath
        ' '
        $RenderError
        ' PS> '
    ) -join ''
}

function Invoke-NinPrompt {
    [cmdletbinding()]
    param()

    $funcName = $script:___promptInfo.Current
    $func = Get-Command -CommandType Function -Name $funcName

    & $func
}
function Enable-NinPrompt {
    <#
    .synopsis
         toggle prompts, breaks if prompts aren't exported
    .notes
        setting value to a function, vs name, *might* make it more stable

        what works?
            - 1]
                - value = name as string
                - export-ModuleMember on the privateFunc Prompts
            - 2]
                - value = name as string
                - do not export ModuleMembers
                - then $error must be referenced as $error

            - 3]
                - value = name as string
                - function set global:
                - regular $error

    #>
    param(
        [ValidateSet(
            '__prompt_noModuleLoaded',
            '__prompt_usingColorExperiment_v2',
            '__prompt_usingColorExperiment_v1',
            '__safePrompt_Sorta',
            'systemDefaultPrompt',
            'ColorBasic',
            'OriginalPrompt',
            '__safePrompt_blah'

        )]
        [Parameter()]
        [string]$ConfigName = 'ColorBasic'
    )

    '__prompt_noModuleLoaded'
    '__prompt_usingColorExperiment_v1'

    $funcName = switch ($ConfigName) {
        '__safePrompt_blah' {
            '__safePrompt_blah'
        }
        '__safePrompt_Sorta' {
            '__safePrompt_Sorta'
        }
        'ColorBasic' {
            '__yellow'
        }
        'OriginalPrompt' {
            'OriginalPrompt'
        }
        default {
            '__systemDefaultPrompt'
        }
    }
    $script:___promptInfo.Current = $funcName
    # $global:prompt = __safePrompt
    # Set-Item -Path 'function:\prompt' -Value __safePrompt
    # Set-Item -Path 'function:\prompt' -Value $ConfigName
    # $custom = Get-Item -Path function:\$ConfigName
    # Set-Item -Path 'function:\global:prompt' -Value $ConfigName
    # 'param {0} -> func:\{1}' -f @($ConfigName, $funcName) | Write-Debug
    # Write-Warning "$PSCommandPath not safe"
    return

    # Copy-Item -Path "Function:\$FuncName" -Destination function:\prompt
    return
    # $custom = Get-Item -Path function:\$funcName
    # Set-Item -Path 'function:\global:prompt' -Value
    # $function:prompt = $global:$custom
    # $Function:Prompt = Get-Item -Path function:\$FuncName
    # Set-Item -Path 'function:\global:prompt' -Value $custom
}
# $global:OriginalPrompt ??= (Get-Content -ea ignore (Get-Item -ea ignore $Function:prompt))
# Get-Item Function:\global:prompt

function __systemDefaultPrompt {

    "PS $($executionContext.SessionState.Path.CurrentLocation)`n$('>' * ($nestedPromptLevel + 1)) "
    # .Link
    # https://go.microsoft.com/fwlink/?LinkID=225750
    # .ExternalHelp System.Management.Automation.dll-help.xml

}

function __yellow {
    <#
    .synopsis
        minimal (more-so), only dependency is Pwsh
    #>
    $c = @{
        Yellow = $PSStyle.Foreground.FromRgb('#ffff00')
        Gray40 = $PSStyle.Foreground.FromRgb(
            255 * 0.4, 255 * 0.4, 255 * 0.4 )

        Gray80 = $PSStyle.Foreground.FromRgb(
            255 * 0.8, 255 * 0.8, 255 * 0.8 )

        Reset  = $PSStyle.Reset
    }
    @(
        if ($global:Error.count -gt 0) {
            ' '
            $C.Yellow
            $global:Error.count
            ' '
        }
        $C.Gray40
        $PSVersionTable.PSVersion.ToString()
        $C.Gray80
        '🐒> '
        # New-Text -fg gray80 ''
        $c.Reset
    ) -join ''
}



Export-ModuleMember -Function $tmpExport.Functions -Alias $tmpExport.Aliases
