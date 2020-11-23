Function Set-ConsoleEncoding {
    <#
    .synopsis
        changes the powershell session to use an encoding
    .notes
        changing encodings multiple times in code works at least on 'pwsh' and the integrated terminal
    #>
    param(
        [Parameter(Mandatory, Position = 0, HelpMessage = "Which encoding to use?")]
        [ArgumentCompleter([EncodingArgumentCompleter])]
        [EncodingArgumentConverter()]
        [Encoding] $Encoding

        # [Parameter(HelpMessage = ".")][switch]$PassThru
    )

    "Encoding: $Encoding"
    | Write-Debug
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


# Set-ConsoleEncoding