#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Format-ShortTypename'
        'Format-UnorderedList'
        'Format-ShortSciTypeName'
    )
    $publicToExport.alias += @(
        'shortTypeName' # 'Format-ShortTypename'
        'UL'
        'shortType' # 'Format-ShortSciTypeName
    )
}


function Format-UnorderedList {
    <#
    .EXAMPLE
        PS>   @(gi . ; get-date; 'hi', 'world') | ul

            - C:\test\Format-UnorderedList
            - 05/23/2022 20:28:17
            - hi
            - world

    .notes
        render-* implies ansi colors

    .link
        Ninmonkey.Console\Format-ShortTypeName
    .link
        Ninmonkey.Console\Render-ShortTypeName

    #>
    [Alias('UL')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$InputObject
    )
    begin {
        $Items = [list[object]]::new()
    }
    process {
        $Items.AddRange( $InputObject )
    }
    end {
        $Items | Join-String -sep "`n - " -op "`n - " -os "`n"
    }
}
$script:__moduleExists = @{
    'ClassExplorer' = [bool](Get-Module 'ClassExplorer')
}

function Format-ShortSciTypeName {
    <#
    .synopsis
        Abbreviate  TypeNames from any [Object] or [Type] info
    .EXAMPLE
        PS> [System.Management.Automation.VerboseRecord] | shortTypeName
        PS> gi env: | ShortType
    .EXAMPLE
        PS> Format-ShortSciTypeName -NoColor -InputObject (Get-Item env:)

                [Dictionary<TKey, TValue>.ValueCollection]

    .notes
        as a fallback, use: <Format-ShortTypeName>. I didn't put a gcm test in there

        requires <https://github.com/SeeminglyScience/ClassExplorer>
        is assumed internal only
        see: <https://github.com/SeeminglyScience/ClassExplorer/blob/a5aa12af456f6d10a233428460af0fbfbd0f24aa/src/ClassExplorer/Internal/_Format.cs>

    .link
        https://github.com/SeeminglyScience/ClassExplorer
    .link
        Ninmonkey.Console\Format-ShortTypeName
    #>
    # [AssumeExperimental()] # attribute NYI
    # [SupportsEnvNoColor()] # attribute NYI
    # [RequiresModule('ClassExplorer')] # attribute NYI
    [OutputType('System.String')]
    [Alias('shortType')]
    param(
        # any object or typeinfo instance
        [AllowNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,
        [switch]$NoColor
    )
    process {
        if ($null -eq $InputObject) {
            return # $null?
        }
        if ($InputObject -is 'type') {
            $Target = $InputObject
        } else {
            $Target = $InputObject.GetType()
        }
        if (! $script:__moduleExists['ClassExplorer'] ) {
            $target | Format-ShortTypeName
            return
        }
        $name = [ClassExplorer.Internal._Format]::Type($Target)
        | Join-String -op '[' -os ']'
        if ($Env:NO_COLOR -or $NoColor) {
            return $Name | StripAnsi
        }
        return $Name
    }
}

function Format-ShortTypeName {
    <#
    .EXAMPLE
        PS> [System.Management.Automation.VerboseRecord] | shortTypeName

            [VerboseRecord]
    .example

        PS>
        @( Get-Date; Gi . ;
            [System.Management.Automation.VerboseRecord]
            (gi fg:\)
        ) | ShortTypeName

            [DateTime]
            [IO.DirectoryInfo]
            [VerboseRecord]
            [RgbColorProviderRoot]
    .notes
        render-* implies ansi colors

    .link
        Ninmonkey.Console\Format-ShortTypeName
    .link
        Ninmonkey.Console\Render-ShortTypeName

    #>
    [Alias('shortTypeName')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )
    process {
        if ($InputObject -is 'type') {
            $Target = $InputObject
        } else {
            $Target = $InputObject.GetType()
        }

        $Target.FullName -replace '^System\.(Management.Automation\.)?', '' -replace '^PoshCode\.Pansies', 'Pansies'
        | Join-String -op '[' -os ']'
    }
}
