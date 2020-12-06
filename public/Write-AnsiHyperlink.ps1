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
    .notes
        this function is a WIP
        behaviours:
            - vscode: Does not work well when spaces are in the path

        Not all terminals create clickable urls without Ansi escapes.

        todo:
            - [ ] extract, create Write-Hyperlink normal/markdown without needing to use -NoAnsi
    .example
        PS> Write-AnsiHyperlink 'google.com' 'search'
            # clickable url displayed as 'search'

        PS> Write-AnsiHyperlink 'google.com' 'search' -NoAnsi
            # url displayed as 'http://google.com/'
    #>
    [CmdletBinding()]
    param(
        #The Uri that you wish to have as part of the hyperlink
        #The label text that will actually be shown in Windows Terminal
        [Parameter(Mandatory, ValueFromPipeline)][UriBuilder]$Uri,
        [ValidateNotNullOrEmpty()][String]$Label = $Uri.uri,

        # Allows you to automatically disable this by setting a $PSDefaultParameterValues
        [Parameter()]
        [Alias('PassThru')]
        [switch]$NoAnsi,

        # output raw markdown instead
        [Parameter()][switch]$AsMarkdown
    )

    $e = [char]27
    $template = @{
        # 0 = uri, 1 = label
        clickableUri = "${e}]8;;{0}${e}`\{1}${e}]8;;${e}`\"
        markdown     = '[{1}]({0})'
        textUri      = '<{0}>'
    }
    # $clickableUri = -f $Uri.uri, $Label

    if ($NoAnsi) {
        if ($AsMarkdown) {
            $template.markdown -f @(
                $Uri.Uri
                $Label
            )
            return
        } else {
            $template.textUri -f $Uri.Uri
            return
        }
    }


    if ($AsMarkdown) {
        $Markdown = $template.markdown -f @(
            $Uri.Uri
            $Label
        )
        $template.clickableUri -f @(
            $Uri.Uri
            $Markdown
        )
        return

    } else {
        $template.clickableUri -f @(
            $Uri.Uri
            $Label
        )
        return
    }


    #         '[{0}]({1})' -f @(
    #             $Label
    #             $Uri.Uri.ToString()
    #         )
    #         return
    #     } else {
    #         $Uri.uri.ToString()
    #         return
    #     }
    # } else {
    #     $e = [char]27
    #     $clickableUri = "${e}]8;;{0}${e}`\{1}${e}]8;;${e}`\" -f $Uri.uri, $Label
    # }

    # if ($AsMarkdown) {
    #     '[{0}]({1})' -f @(
    #         $Label
    #         $Uri.Uri.ToString()
    #     )
    #     return
    # } else {
    #     $Uri.uri.ToString()
    #     return
    # }
}
# seee:  C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Ansi\consolidate\Write-AnsiHyperlink - edge cases.ps1
# . 'C:\Users\cppmo_000\Documents\2020\powershell\MyModules_Github\Ninmonkey.Console\tests\public\test_Write-AnsiHyperlink.ps1'
# if ($AsMarkdown) {

# } else {
#     if ($NoAnsi) {

#     }

# }
# if ($AsMarkdown) {
#     '[{0}]({1})' -f @(
#         $Label
#         $Uri.Uri.ToString()
#     )
# }
# if ($NoAnsi) {
# }

# $e = [char]27
# "${e}]8;;{0}${e}`\{1}${e}]8;;${e}`\" -f $Uri.uri, $Label
# }
