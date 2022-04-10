
function __safePrompt {
    <#
    .synopsis
        zero dependency prompt, that includes errors
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
        "`n", ($Error.Count ?? 0),
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

    Write-Warning 'not-imported: _fmt_FilepathWithoutUsernamePrefix'


    # if ($Enable) {
    #     $global:prompt = $script:__safePrompt
    # }

    $colorPrefix = New-Text -fg gray50 'nin'

    $renderPath = Get-Location
    # | _fmt_FilepathWithoutUsernamePrefix -ReplaceWith $colorPrefix
    # | _fmt_FilepathForwardSlash

    $errorCount = $Error.count ?? 0
    # $errorString = ($Error.count ?? 0)
    $errorColor = switch ($errorCount) {
        { $_ -ge 1 -and $_ -lt 5 } {
            'orange' ; break;
        }
        { $_ -ge 5 -and $_ -lt 12 } {
            'darkorange'; break;
        }
        { $_ -gt 12 -and $_ -lt 20 } {
            'orangered'; break;
        }
        { $_ -ge 20 } {
            'red'; break;
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
        # ($Error.Count ?? 0)
        $renderPath
        ' '
        $RenderError
        ' PS> '
    ) -join ''
}
function Enable-SafePrompt {
    param(
        [ValidateSet('__safePrompt', '__safePrompt_Sorta')]
        [Parameter()]
        [string]$ConfigName = '__safePrompt'
    )
    # $global:prompt = __safePrompt
    # Set-Item -Path 'function:\prompt' -Value __safePrompt
    Set-Item -Path 'function:\prompt' -Value $ConfigName
}


Export-ModuleMember -Function 'Enable-SafePrompt'

function gocode {
    <#
    .synopsis
        open file in vs code: similar to __safePrompt, minimal, always works
    .example
        PS> gi foo.ps1 | gocode
    .example
        PS> gocode (~/foo/bar.ps1
    .link
        __safePrompt

    #>
    param(
        [Parameter(ValueFromPipeline, Position = 0, Mandatory)]
        $Path
    )
    if ( Test-Path $Path ) {
        & code.cmd @(
            '--goto'
            Get-Item -ea stop $Path | Join-String -DoubleQuote
        )
    }
}

Export-ModuleMember -Function 'goCode'
