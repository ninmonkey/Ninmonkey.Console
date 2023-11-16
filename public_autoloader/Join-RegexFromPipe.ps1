# 'not enabled'

# if ( $publicToExport ) {
#     $publicToExport.function += @(
#         'Join-RegexFromPipe'
#     )
#     $publicToExport.alias += @(
#     )
# }
# # new


# function Join-RegexFromPipe {
#     [CmdletBinding()]
#     param(
#         [Parameter()][switch]$AsRegex,
#         # [Parameter()][switch]$AsText,

#         [Parameter(ValueFromPipeline)]
#         [string[]]$InputText
#     )

#     begin {
#         $segments = [list[string]]::new()
#     }
#     process {
#         $segments.AddRange( @($InputText) )
#     }
#     end {
#         if ($AsRegex) {
#             Join-Regex -Regex $segments
#             return
#         }
#         Join-Regex -Text $Segments
#     }
# }
