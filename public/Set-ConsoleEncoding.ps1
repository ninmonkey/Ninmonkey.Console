Function Set-ConsoleEncoding {
    param(
        [Parameter(
            Mandatory, Position = 0,
            HelpMessage = "Which encoding to use?")]
        [ValidateSet('Utf8', 'Utf16-LE', 'Unicode')]
        [string]$EncodingName,

        [Parameter(
            Mandatory = $false, HelpMessage = "Do not print to info stream")]
        [switch]$NoOutput

    )
    switch ($EncodingName) {
        { $_ -in 'utf16le', 'unicode' } {
            h1 'uni16'
            $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UnicodeEncoding]::new()
            break
        }
        'utf8' {
            $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
            break
        }
        default {
            $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
            break
        }
    }

    if (! $NoOutput ) {
        h1 "Set encoding: $EncodingName"
        Get-ConsoleEncoding
        Label 'See also: Autocomplete [enum]' '[Microsoft.PowerShell.Commands.TextEncodingType]'
    }
}
