﻿Function Get-ConsoleEncoding {
    <#
    .description
        get encoding config, optionally test
    .example
        Get-Encoding
    .example
        Get-Encoding -Test
    .example
        Get-Encoding Full
    .link
        Ninmonkey.Console\Set-ConsoleEncoding
    #>
    param(
        [Parameter(Mandatory = $false, position = 0)]
        [ValidateSet('Full', 'Short', 'FullAlternate')]
        [string]$DisplayMode = 'Short',

        [Parameter()][switch]$Test
    )

    $config = [ordered]@{
        'OutputEncoding'            = $OutputEncoding
        '[console]::InputEncoding'  = [console]::InputEncoding
        '[console]::OutputEncoding' = [console]::OutputEncoding
        # chcp = chcp.exe
        # 'chcp = {0}' -f (chcp) | Write-Debug
    }
    switch ($DisplayMode) {
        'Full' {
            Label 'Encoding' 'Full'

            $config.GetEnumerator() | ForEach-Object {
                Label $_.Key
                $_.Value
            }
            break
        }
        'FullAlternate' {
            Label 'Encoding' 'FullAlternate'

            $config.GetEnumerator() | ForEach-Object {
                [pscustomobject]@{
                    # should be format or type data
                    PSTypeName             = 'nin.ConsoleEncodingInfo.Full'
                    Name                   = $_.Key
                    Encoding               = $_.Value.EncodingName
                    GetEncoder             = $_.value.GetEncoder()
                    GetEncoderType         = $_.value.GetEncoder().GetType().FullName
                    GetEncoderInternalType = $_.value.GetEncoder().GetType().UnderlyingSystemType
                    GetDecoder             = $_.value.GetDecoder()
                    isSingleByte           = $_.Value.IsSingleByte
                }
            }
            # | Format-List
            break

        }
        'Test' {

        }
        Default {
            $config.GetEnumerator() | ForEach-Object {
                [pscustomobject]@{
                    PSTypeName   = 'nin.ConsoleEncodingInfo.Short'
                    Name         = $_.Key
                    Encoding     = $_.Value.EncodingName
                    CodePage     = $_.Value.CodePage
                    isSingleByte = $_.Value.IsSingleByte
                }
            }
            #| Format-Table
        }
    }
    # move to a Test-ConsoleEncodingSupport
    # if ($Test) {
    #     h1 'test1'
    #     "`u{1F408}" #cat
    #     ($OutputEncoding, [console]::InputEncoding, [console]::OutputEncoding).EncodingName
    #     "`u{1F408}" #cat
    #     hr
    #     "`u{1F412}" #monkey
    #     hr
    #     'adsfs', '-', ( [char]::ConvertFromUtf32(0x1f412) ), '-', 'end' -join ''
    #     hr
    #     'adsfs', "`u{1F412}", '-', ( [char]::ConvertFromUtf32(0x1f412) ), '-', 'end' -join ''
    #     h1 'end'
    # }
}
Get-ConsoleEncoding FullAlternate