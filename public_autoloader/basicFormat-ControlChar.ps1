#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Format-BasicControlChar'  # 'formatCtrl', 'To->SafeAnsiEscapedString'
    )
    $publicToExport.alias += @(
        'formatCtrl' # 'Format-BasicControlChar'
        'To->SafeAnsiEscapedString' # 'Format-BasicControlChar'
    )
}
<#

    Original sketchalso:
    function FormatSafeControlChar {
# standalone. for this is super not optimized <https://github.com/ninmonkey/Ninmonkey.Console/blob/main/public/Format-ControlChar.ps1#L19>
param( [string]$InputText
    $InputText.EnumerateRunes() | % {
        if ($_.Value -ge 0 -and $_.Value -le 0x1f) {
            return [Char]::ConvertFromUtf32( $_.Value + 0x2400 )
        }
        else {
            $_
        }
    } | Join-String -sep ', '
    #>

function Format-BasicControlChar {
    # standalone. for this is super not optimized <https://github.com/ninmonkey/Ninmonkey.Console/blob/main/public/Format-ControlChar.ps1#L19>
    <#
    .SYNOPSIS
        Replace unsafe ascii escapes or bytes, to safe replacements.
    .DESCRIPTION
        A more minimal version of Format-ControlChar. No requirements.
    .example
        $sample = 'hi 🐵🐒 world', @(
            0..50 | % { [Char]::ConvertFromUtf32( $_ ) } | Join-String )
        hr -fg orange
        $sample
        hr
        $sample | format-BasicControlChar
        Format-ControlChar $sample
    #>
    [ALias('To->SafeAnsiEscapedString', 'formatCtrl')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [string]$InputText
    )
    process {
        throw "Not working right, maybe stale types."

        $InputText.EnumerateRunes() | ForEach-Object {
            if($null -eq $_ -or 0 -eq $_.value) { # maybe, because null and null terminating
               return "[`u{2400}]"
            }
            if ($_.Value -ge 0 -and $_.Value -le 0x1f) {
                return [Char]::ConvertFromUtf32( $_.Value + 0x2400 )
            }
            else {
                $_
            }
        }
    }
}