if ( $publicToExport ) {
    $publicToExport.function += @(
        'SafePrompt'
        'Invoke-PwshNoProfile'
    )
    $publicToExport.alias += @(
        # 'SafePrompt' # 'SafePrompte'
        'pwshNoProfile' # 'Invoke-PwshNoProfile'
    )
}

function SafePrompt {
    #minimalPromptWithErrorCountAndNewlines Nodependency
    @(
        $ec = $error.count
        $ec -gt 0 ? $ec : ''
        Get-Location; 'PS> '

    ) -join "`n"
}

function Invoke-PwshNoProfile {
    #minimalPromptWithErrorCountAndNewlines Nodependency
    [Alias('pwshNoProfile')]
    param(
        # which template/style
        [Parameter(Position = 0)]
        [validateSet('Basic', '')]
        [string]$Config = 'basic',

        [switch]$AsBase64
    )
    $sbSafePrompt = { function prompt {
            @(
                $ec = $error.count
                $ec -gt 0 ? $ec : ''
                Get-Location; 'PS> '

            ) -join "`n"
        } }

    if ($AsBase64) {
        throw 'not implemented'
    }
    switch ($Config) {
        'Basic' {
            pwsh -Nop -C $sbSafePrompt
        }
        'Process' {
            "'$config' NotImplemented"
            Start-Process 'pwsh' -WorkingDirectory (Get-Item . ) -NoNewWindow -UseNewEnvironment - -args @('-NoProfile', '-C')
        }
        default {
            "'$config' NotImplemented"
        }
    }
    # attempt non-base64 encoded command
    # or
    # start-process 'pwsh' -WorkingDirectory (gi . ) -NoNewWindow -UseNewEnvironment -  -args @()
}