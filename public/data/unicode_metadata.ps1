
# missing (utfbom/non-bom and pwsh specific)


<#
this is not to replace unicode data and code ranges,
rather to suppliment or summarize important info
#>
$_unicode_metadata = @{
    Docs              = @{
    }
    'MaxValue'        = 0x10ffff

    'Ranges'          = @{
        'C0 Control Codes'        = @{
            First = 0x00
            Last  = 0x1f
        }
        'C1 Control Codes'        = @{
            First = 0x80
            Last  = 0x9f
        }
        'C0 Control Char Symbols' = @{
            First = 0x2400
            # technically space isn't control, but the symbol exists
            #0x241f
            Last  = 0x2f20
        }

        'SurrogatePairs'          = @{
            First = 0xD800
            Last  = 0xDFFF
        }
    }

    'Named_Codepoint' = @{
        'Null'                = 0x00
        'Delete'              = 0x1f
        'Control Char Symbol' = @{
            'Null'   = 0x2400
            'Delete' = 0x2421
        }
    }
}

$_unicode_web_query = @{

    'Fileformat.info' = @{
        # ex: 2400
        'Codepoint' = 'https://www.fileformat.info/info/unicode/char/{{codepoint_hex}}/index.htm'
        # ex: 'Cc'
        'Category'  = 'https://www.fileformat.info/info/unicode/category/Cc/index.htm'
    }
}