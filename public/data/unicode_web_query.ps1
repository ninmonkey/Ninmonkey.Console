
$_unicode_web_query = @{

    'Fileformat.info' = @{
        # ex: 2400
        'Codepoint'      = 'https://www.fileformat.info/info/unicode/char/{{codepoint_hex}}/index.htm'

        # ex: 'Cc' and 'index'
        # 'https://www.fileformat.info/info/unicode/category/Cc/index.htm'
        'Category_Index' = 'https://www.fileformat.info/info/unicode/category/{{category}}/list.htm'

        # ex: 'Cc' and 'index'
        # 'https://www.fileformat.info/info/unicode/category/Cc/list.htm'    }
        'Category2_List' = 'https://www.fileformat.info/info/unicode/category/{{category}}/list.htm'
    }
}