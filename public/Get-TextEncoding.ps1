# Set-Alias 'Get=Encoding' -Value Get-TextEncoding -Description 'until the wrapper for both encodings is creating, link to this one'

function Get-TextEncoding {
    <#
    .synopsis
        returns [Text.Encoding] types
    .example
        PS> Get-TextEncoding -Codepage 65001
    .example
        PS> Get-TextEncoding -EncodingName 'utf-8'
        PS> Get-TextEncoding -EncodingName 'utf-8', 'utf-16'

    .notes
        todo
        - add encodings not found by -List
        - add non-text encodings (maybe extract to another command)
                - allow param to read encodng used by an object/struct

        signatures:

            GetEncoding(int codepage)
            GetEncoding(string name)

            GetEncoding(
                int codepage,
                System.Text.EncoderFallback encoderFallback,
                System.Text.DecoderFallback decoderFallback)


            GetEncoding(
                string name,
                System.Text.EncoderFallback encoderFallback,
                System.Text.DecoderFallback decoderFallback)

    see also:
        PS> [System.Drawing.Imaging.Encoder*

        Encoder                           EncoderFallbackBuffer             EncoderParameterValueType
        EncoderExceptionFallback          EncoderFallbackException          EncoderReplacementFallback
        EncoderExceptionFallbackBuffer    EncoderParameter                  EncoderReplacementFallbackBuffer
        EncoderFallback                   EncoderParameters                 EncoderValue

    > for information on defining a custom encoding, see the documentation for the "Encoding.RegisterProvider method"
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param (
        # [Parameter(Mandatory, Position=0, HelpMessage="doc")]
        # [TypeName]$ParameterName

        [Alias('Name')]
        [Parameter(
            ParameterSetName = 'ByName',
            Mandatory, Position = 0)]
        [string[]]$EncodingName,

        # [Alias('Name')]
        [Parameter(
            ParameterSetName = "ByNum",
            Mandatory, Position = 0)]
        [int]$Codepage,

        [Parameter(
            ParameterSetName = "ListOnly",
            Mandatory
        )][switch]$List,


        [Parameter()]
        [System.Text.EncoderFallback]
        $EncoderFallback,

        [Parameter()]
        [System.Text.DecoderFallback]
        $DecoderFallback

    )

    begin {
        if ($List ) {
            return [Text.Encoding]::GetEncodings()
        }
        if ($null -ne $DecoderFallback -or $null -ne $EncoderFallback) {
            throw "NYI: Get-TextEncoding() using params: EncoderFallback, DecoderFallback"
        }
    }
    Process {
        switch ($PSCmdlet.ParameterSetName) {
            'ListOnly' {
                return
            }
            'ByName' {
                foreach ($name in $EncodingName) {
                    $encoding = [Text.Encoding]::GetEncoding( $name )
                    $encoding
                }
                break

            }
            'ByNum' {
                $encoding = [Text.Encoding]::GetEncoding( $Codepage )
                $encoding
                break

            }

            default {
                break
                # throw "Unexpected ParameterSetName: $($PSCmdlet.ParameterSetName)"
                Write-Error "Unexpected ParameterSetName: $($PSCmdlet.ParameterSetName)"
            }

        }

    }
}

if ($false -and $run_test) {
    # . ".\${PSScriptRoot}\tests\test_Get-Encoding.ps1"
    . "${PSScriptRoot}\tests\test_Get-TextEncoding.ps1"
}
