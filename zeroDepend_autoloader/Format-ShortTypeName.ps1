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
        'join.UL'
        'shortType' # 'Format-ShortSciTypeName
    )
}


function Format-UnorderedList {
    <#
    .SYNOPSIS
        Pipe a list of something, convert to an Unordered List, or list of checkboxes
        fairly powerfull
    .EXAMPLE
        PS># pressing tab on -Options will cycle templates

            'a'..'f' | ul -Options <tab>

    .EXAMPLE
        PS>   @(gi . ; get-date; 'hi', 'world') | ul

            - C:\test\Format-UnorderedList
            - 05/23/2022 20:28:17
            - hi
            - world
    .example
        PS>
        h1 'experimental features?'

        Get-ExperimentalFeature | ? Enabled -Not
        | %{ '{0} : {1}' -f @(  $_.Name.PadRight(30, ' '), $_.Description  ) }
        | Ul -BulletStr 🧪 -Options @{ ULHeader = (hr 0) ; ULFooter  = (hr 0); }

    output:
            # experimental features?
            ------------------------------------------------------------------------------
            🧪 PSAnsiRenderingFileInfo        : Enable coloring for FileInfo objects
            🧪 PSCommandNotFoundSuggestion    : Recommend potential commands based on fuz
            🧪 PSLoadAssemblyFromNativeCode   : Expose an API to allow assembly loading f
            🧪 PSNativeCommandArgumentPassing : Use ArgumentList when invoking a native c
            🧪 PSNativePSPathResolution       : Convert PSPath to filesystem path, if pos
            🧪 PSSubsystemPluginModel         : A plugin model for registering and un-reg
            ------------------------------------------------------------------------------
    .EXAMPLE
        PS>
            ls -File C:\Temp\ | sort lastWriteTime -Descending -Top 4 | % Name
            | UL -BulletStr '→' -Options @{
                ULHeader =  @( (hr 1) ; Label "Newest Files" 'c:/temp'  ) | Join-String
                ULFooter  = (hr 0);
            }
    output:
            ----------------------
            Newest Files: c:/temp
            → delta_this.json
            → test-Dotsource.ps1
            → fzf.man.txt
            → forGrep3.txt
            ----------------------

    .example
        PS> 'before'
            Get-Process | Get-Random -Count 5 | % Name
            | UL -BulletStr '👍' -Options @{ ULHeader = (hr 0) ; ULFooter  = (hr 0); }
            'end'

    output:

        before
        ------------------------------------------------------------------------------
        👍 firefox
        👍 svchost
        👍 fdhost
        👍 svchost
        👍 python3.9
        ------------------------------------------------------------------------------
        end

    .notes
        render-* implies ansi colors

    .link
        Ninmonkey.Console\Format-ShortTypeName
    .link
        Ninmonkey.Console\Render-ShortTypeName

    #>
    [Alias(
        'UL',
        'join.UL'
    )]
    param(
        # list of objects/strings to add
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [AllowNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]]$InputObject,

        # todo: Make custom arg completer
        # with parameter, so I can say 'use set X'
        # like 'arrows', or 'bars', or 'checkbox'
        [ArgumentCompletions(
            '•', '-', '‣',
            '[ ]', '[x]',
            '→', '☑️', '✅', '✔', '❌', '⛔', '⚠', '✔', '🧪', '📌', '👍', '👎'
        )]

        # sets bullet types, but if overriden in -Options, Options has priority
        [string]$BulletStr = '-',
        [ArgumentCompletions(
            '@{ ULHeader = (hr 0) ; ULFooter  = (hr 0); }',
@'
@{ ULHeader =  @( (hr 1) ; Label "Newest Files" "c:/temp"  ) | Join-String ; ULFooter  = (hr 0); }
'@, #-replace '\r?', '',
# @'
# @{  todo: Can I use the -replace operator, acting as a const expression?
#     ULHeader =  @( (hr 1) ; Label "Newest Files" "c:/temp"  ) | Join-String
#     ULFooter  = (hr 0);
# }
# '@, #-replace '\r?', '',
            '@{ BulletStr = "•" }'
        )]
        [hashtable]$Options = @{}
    )
    begin {
        $Config = mergeHashtable -OtherHash $Options -BaseHash @{
            BulletStr    = $BulletStr
            PaddingStr   = ' '
            BulletPrefix = "`n"
            ULHeader     = ''
            ULFooter     = ''
        }
        [Collections.Generic.List[Object]]$Items = @()
    }
    process {
        foreach ($str in $InputObject) {
            $items.Add( $str )
        }
    }
    end {
        <#
        Tip: Join-String gracefully handles empty types, gracefully.
        $null values are not passed as input

        #>
        # was

        $joinStringSplat = @{
            Separator    = "`n $StrBullet "
            OutputPrefix = "`n $StrBullet "
            OutputSuffix = "`n"
        }
        $joinStringSplat = @{
            # -sep and prefix are normally the same
            Separator    = '{0}{1}{2}{1}' -f @( # "`n $StrBullet "
                $Config.BulletPrefix
                $Config.PaddingStr
                $Config.BulletStr
            )
            OutputPrefix = '{0}{1}{2}{1}' -f @( # "`n $StrBullet "
                $Config.BulletPrefix
                $Config.PaddingStr
                $Config.BulletStr
            )
            OutputSuffix = $Config.BulletPrefix
        }

        $Items
        | Join-String @joinStringSplat
        | Join-String -op $COnfig.ULHeader -os $Config.ULFooter


        # original:
        # $Items | Join-String -sep "`n $StrBullet " -op "`n $StrBullet " -os "`n"
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
