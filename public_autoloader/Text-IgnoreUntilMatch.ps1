#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(

        '_textIgnoreAfterMatch'
        '_textIgnoreBeforeMatch'
    )
    $publicToExport.alias += @(

        'Text->IgnoreAfterMatch' # '_textIgnoreAfterMatch'
        'Text->IgnoreBeforeMatch' # '_textIgnoreBeforeMatch'
        # 'Text->IgnoreUntilMatch' # '_textIgnoreBeforeMatch'


    )
}

function _textIgnoreAfterMatch {
    <#
    .synopsis
        [copy with inverted logic] ignore all text After a pattern is found, then return the rest as normal
    .notes
        name:
            Text->IgnoreBefore / Filter->IgnoreBefore ?
    .link
        Ninmonkey.Console\_textIgnoreAfterMatch
    .link
        Ninmonkey.Console\_textIgnoreAfterMatch
    #>
    [Alias(
        # 'Text->IgnoreAfterMatch'
        'Text->IgnoreAfterMatch'
        # 'Text->IgnoreAfter'
        # 'Text->IgnoreUntil'
        # '
    )]
    [cmdletbinding()]
    param(
        <#
           STDIN from pipe
            Null is allowed for the user's conveinence.
            allowing null makes it easier for the user to pipe, like:
            'gc' without -raw or '-split' on newlines
        #>
        [Alias('Text')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$InputText,

        # [Alias('Regex')]
        [parameter(Mandatory, Position = 1)]
        [string]$Pattern,

        # match literals, or a regex?
        [Parameter()][switch]$Regex,

        # to include text that matched, instead of dropping the match
        [Parameter()][switch]$IncludeMatch
    )
    begin {
        $state_hasMatched = $false
        [list[object]]$items = [list[object]]::New()
        if (!  $Regex) {
            $Pattern = [regex]::escape( $Pattern )
        }

    }
    process {
        if ($null -eq $InputText) {
            return
        }
        $items.AddRange( $InputText ) #.ToString() )
    }

    end {
        $items | ForEach-Object {
            $line = $_
            if ($line -match $Pattern) {
                $state_hasMatched = $true
                if ( $PassThru ) {
                    return $Line
                }
            }

            if (! $state_hasMatched) {
                return $line
            }

            return
        }
    }
}

function _textIgnoreUntilMatch {
    <#
    .synopsis
        filter / ignore all text until a pattern is found, then return the rest as normal
    .link
        Ninmonkey.Console\_textIgnoreUntilMatch
    .link
        Ninmonkey.Console\_textIgnoreAfterMatch
    #>
    [Alias(
        'Text->IgnoreUntilMatch',
        'Text->IgnoreBeforeMatch'

    )]
    [cmdletbinding()]
    param(
        <#
           STDIN from pipe
            Null is allowed for the user's conveinence.
            allowing null makes it easier for the user to pipe, like:
            'gc' without -raw or '-split' on newlines
        #>
        [Alias('Text')]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]]$InputText,

        # [Alias('Regex')]
        [parameter(Mandatory, Position = 1)]
        [string]$Pattern,

        # match literals, or a regex?
        [Parameter()][switch]$Regex,

        # to include text that matched, instead of dropping the match
        [Parameter()][switch]$IncludeMatch
    )
    begin {
        $state_hasMatched = $false
        [list[object]]$items = [list[object]]::New()
        if (!  $Regex) {
            $Pattern = [regex]::escape( $Pattern )
        }

    }
    process {
        if ($null -eq $InputText) {
            return
        }
        $items.AddRange( $InputText ) #.ToString() )
    }

    end {
        $items | ForEach-Object {
            $line = $_
            if ($line -match $Pattern) {
                $state_hasMatched = $true
                if ( ! $PassThru ) {
                    return
                }
            }

            if (! $state_hasMatched) {
                return
            }

            return $Line
        }
    }
}
