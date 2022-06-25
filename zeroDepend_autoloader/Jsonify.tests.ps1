Describe 'Jsonify Conversions' {
    BeforeAll {
        Import-Module Ninmonkey-Console -Force
    }
    Describe 'ToJsonify' {
        BeforeAll {
            $color_int = 16711680
            $color_red = [PoshCode.Pansies.RgbColor]::FromRgb( $color_int )
        }
        It {
            Set-ItResult -Pending -Because 'finishing tester first'
            $jify = $color_red | Jsonify
            $jify | Should -Be @{ NinTypeName = 'RgbColor' ; RGB = 16711680 }
        }

    }
    <#
        @(

        $sample = @( 2342354, 'sdfs', (Get-Item .), 'foo' )

        H1 'none'
        $sample | to->Json


        H1 'files'
        $sample | ConvertTo-Jsonify | to->Json

        H1 'none'
        [rgbcolor]'red' | to->Json


        H1 'files'
        @(
            Get-Item .
            [rgbcolor]'red'
        ) | ConvertTo-Jsonify | to->Json

        H1 'raw: convertFrom'
        @(
            Get-Item .
            [rgbcolor]'red'
        )
        | ConvertTo-Jsonify | to->Json
        | ConvertFrom-Json

        H1 'raw: convertFrom files plus un-ninify'
        @(
            Get-Item .
            [rgbcolor]'red'
        )
        | ConvertTo-Jsonify | to->Json
        | ConvertFrom-Json | ConvertFrom-Jsonify -Debug
        # | Write-Host
    )
    #>


    It 'Mostly Visual Tests' -Skip {
        @(

            $sample = @( 2342354, 'sdfs', (Get-Item .), 'foo' )

            H1 'none'
            $sample | to->Json


            H1 'files'
            $sample | JsoNinfy | to->Json

            H1 'none'
            [rgbcolor]'red' | to->Json


            H1 'files'
            @(
                Get-Item .
                [rgbcolor]'red'
            ) | JsoNinfy | to->Json

            H1 'raw: convertFrom'
            @(
                Get-Item .
                [rgbcolor]'red'
            ) | JsoNinfy | to->Json
            | ConvertFrom-Json

            H1 'raw: convertFrom files plus un-ninify'
            @(
                Get-Item .
                [rgbcolor]'red'
            ) | JsoNinfy | to->Json
            | ConvertFrom-Json | Un-JsoNinfy
            | Write-Host
        )
    }
}
