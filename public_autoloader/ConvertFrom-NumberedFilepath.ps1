#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'ConvertFrom-NumberedFilepath'
    )
    $publicToExport.alias += @(
        'StripNumberedFilepaths'
    )
}

function ConvertFrom-NumberedFilepath {
    <#
            .synopsis
                stripFilepathNumbers |  filepaths from grep or code errors have line numbers appended
            .description
                currently strips line numbers, although VSCode can handle it
                - todo: [ ] returning object with PSPath but line numbers would be ideal
                    - [ ] already implemented in the Dev.Nin\Format-RipGrepResult()
                future:
                    [ ] return VsCode filepath numbers, that are valid objects
                    [ ] should inputtype fileinfo return same value?
                        no, caller, like To->RelativePath() will test before passing to this, a low level, stable function
            .notes
                Naming it remove would be consistent with Remove-AnsiEscapes
                however, remove Filepath could imply it throws out the entire filepath, vs trying to transform
            .example
                PS>
                @(
                    'foo:bar:cat.PS1:345:4'
                    'foo:bar:cat.PS1:345'
                ) | ConvertFrom-NumberedFilepath
                  .
            .outputs
                  [string | None]
            .link
                Dev.Nin\Format-RipGrepResult

            #>
    #
    [Alias(
        'StripNumberedFilepaths'
    )]
    [CmdletBinding()]
    param(
        #piped in text/paths/etc
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [AllowNull()]
        [Parameter(Position = 0, ValueFromPipeline)]
        [string]$Text,

        # toggles regex
        [switch]$StripLastOnly
    )

    begin {
        $Regex = @{
            StripLastNumberOnly = '(:\d+)$'
            StripAllNumbers     = '(:\d+){1,}$'
        }
        $RegexMode = $StriplastOnly ? 'StripLastNumberOnly' : 'StripAllNumbers'
        Write-Debug "Regex: '$RegexMode'"
    }
    process {
        if ($null -eq $Text) {
            return
        }
        $Text -replace $regex[$regexMode], ''
    }
    end {
    }
}

if (! $publicToExport) {
    # ...
}