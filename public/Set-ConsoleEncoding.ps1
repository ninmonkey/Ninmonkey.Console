
# . 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\private\refactor to csharp\EncodingCompletion.ps1'

function __old_Set-ConsoleEncoding {
    <#
    .synopsis
        changes the powershell session to use an encoding
    .notes
        changing encodings multiple times in code works at least on 'pwsh' and the integrated terminal
    #>
    param(
        # Which encoding to use?
        [Parameter(Mandatory, Position = 0)]
        [System.Management.Automation.ArgumentCompleterAttribute([EncodingArgumentCompleter])]
        [EncodingArgumentConverter()]
        [Encoding] $Encoding

        # [Parameter(HelpMessage = ".")][switch]$PassThru
    )

    Write-Warning 'todo: need to use Add-Type else cs class'

    "Encoding: $Encoding"
    | Write-Debug

    # hardcoded example:
    # $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UnicodeEncoding]::new()
    # $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = 4

    Get-ConsoleEncoding | Label 'NewEncoding' -fg magenta
    # switch ($EncodingName) {
    #     { $_ -in 'utf16le', 'unicode' } {
    #         h1 'uni16'
    #         $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UnicodeEncoding]::new()
    #         break
    #     }
    #     'utf8' {
    #         $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    #         break
    #     }
    #     default {
    #         $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
    #         break
    #     }
    # }

    # if (! $NoOutput ) {
    #     h1 "Set encoding: $EncodingName"
    #     Get-ConsoleEncoding
    #     Label 'See also: Autocomplete [enum]' '[Microsoft.PowerShell.Commands.TextEncodingType]'
    # }
}


function Set-ConsoleEncoding {
    param(
        # Which encoding to use?
        # [string] or [encoding]
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet('Utf8', 'Utf16-LE', 'Unicode')]
        [string]$EncodingName

    )
    switch ($EncodingName) {
        { $_ -in 'Utf16-LE', 'Unicode' } {
            H1 'uni16'
            $global:OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UnicodeEncoding]::new()
            break
        }
        'utf8' {
            $global:OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
            break
        }
        default {
            $global:OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
            break
        }
    }

    Label 'Set Encoding' $EncodingName | Write-Information
    Get-ConsoleEncoding
    #  'See also: Autocomplete [enum]' '[Microsoft.PowerShell.Commands.TextEncodingType]'
}
