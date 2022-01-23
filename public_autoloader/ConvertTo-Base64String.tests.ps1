BeforeAll {
    Import-Module Ninmonkey.Console -Force
}

Describe 'ConvertToAndFrom-Base64String' {
    Describe 'Round Trip' {
        BeforeAll {
            $original_string = @'
            0..4
            | Str csv sep ' '

            h1 'someheader'
'@
        }
        It 'utf8' {

            #'future' add non-utf8 enocdings as tests
            $b64_str = $original_string | To->Base64 -Encoding utf8
            $final_string = $b64_str | From->Base64 -encoding Utf8
            $final_string | Should -Be $original_string -Because 'round trip of encode->decode'
        }
        It 'Utf16LE' {
            $original_string = @'
            0..4
            | Str csv sep ' '

            h1 'someheader'
'@
            $b64_str = $original_string | To->Base64 -Encoding Unicode
            $final_string = $b64_str | From->Base64 -encoding Unicode
            $final_string | Should -Be $original_string -Because 'round trip of encode->decode'

        }

    }
}
