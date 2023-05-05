function Invoke-BrowserItem {
    <#
    .SYNOPSIS
    Always open a file in the browser, for local or remote files

    .DESCRIPTION
    local files need the file protocol as the url
    .notes
        Using Invoke-Item might not open a browser 'c:\data\file.html'

        reply to comment: <https://discord.com/channels/180528040881815552/446531919644065804/1091608680652341288>

    .EXAMPLE


    .NOTES
    General notes
    #>

    param(

    )

    $url = 'file:///{0}' -f @( gi -ea 'stop' G:\temp\test.html )
    Start-Process $url

}

$HtmlPath = New-Item -ItemType File -Name 'test.html' -Path (gi temp:\ ) -ea 'ignore'
|| gi 'temp:\test.html' # returns item when either case

$Regex = @{
    IsAUrl = [Regex]::Escape('^https?://')
}

'<html><body><h1>test render</h1></body></html>'
| set-content -path $HtmlPath


$Url = $HtmlPath
if($Url -match $Regex.IsAUrl ) {
    Start-Process $Url
    $url | write-warning
    return
}
write-warning 'was not url'
$finalUrl = 'file:///{0}' -f @( gi -ea 'stop' $Htmlpath  )
$finalUrl | Join-String -op 'FinalUrl: ' | write-warning

Start-Process $Finalurl -verbose
return
# $HtmlPath = New-Item -path 'temp:\test.html' -passThru # G:\temp\test.html




$UrlParam = 'g:\temp\\'



$url = 'file:///{0}' -f @( gi -ea 'stop' $Htmlpath  )
Start-Process $url