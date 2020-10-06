function Write-AnsiHyperlink {
    <#
    .SYNOPSIS
        Creates an ANSI Hyperlink in a supported terminal such as Windows Terminal 1.4
    .description
        Warning!: Displayed url and actual url are different, don't use unsafe input

        Original code is from
            [JustinGrote: gist](https://gist.github.com/JustinGrote/50a43909f87710a97865141ec7f06544)
        for details for using ANSI hyperlink escape sequences, see:
            [egmontkob/Hyperlinks_in_Terminal_Emulators.md ](https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda)
    .example
        PS> Write-AnsiHyperlink 'google.com' 'search'
            # clickable url displayed as 'search'

        PS> Write-AnsiHyperlink 'google.com' 'search' -DisableAnsi
            # url displayed as 'http://google.com/'
    #>
    [CmdletBinding()]
    param(
        #The Uri that you wish to have as part of the hyperlink
        [Parameter(Mandatory, ValueFromPipeline)][UriBuilder]$Uri,
        #The label text that will actually be shown in Windows Terminal
        [ValidateNotNullOrEmpty()][String]$Label = $Uri.uri,


        [Parameter(
            HelpMessage = 'Allows you to automatically disable this by setting a $PSDefaultParameterValues')]
        [Alias('PassThru')]
        [switch]$DisableAnsi
    )

    if ($DisableAnsi) {
        return $Uri.uri.ToString()
    }

    $e = [char]27
    "${e}]8;;{0}${e}`\{1}${e}]8;;${e}`\" -f $Uri.uri, $Label
}