#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        # '?? Format-UnorderedList'
        # '?? Format-JoinLines'
        'StrFormat-NormalizeLines'
        'StrFormat-Replace'
        'StrJoin-Lines'
        'StrSplit-Lines'
    )
    $publicToExport.alias += @(
        # 'UL'      # 'Format-UnorderedList'
        # 'join.UL' # 'Format-UnorderedList'
    )
}
# Requires: Ninmonkey.Console\zeroDepend_autoloader\Format-ShortTypeName.ps1

'📚 NOT FINISHED : Experiment ==> init ==>  C:\Users\cppmo_000\SkyDrive\Documents\2021\powershell\My_Github\ninmonkey.console\public_autoloader\join.star\JoinStr.Format-Indent.ps1/02d9a678-f388-4f18-bc03-f8f4939bb216' | Write-Warning
function StrSplit-Lines {
    # Split on lines parameter set experiment
    <#
    .SYNOPSIS
        Split on common delimiters

    .example
        PS> 0..4 -join "`r`n"
        | StrSplit-Lines -SplitPattern '\n'
        | fcc | Should -BeExactly '0␍1␍2␍3␍4'

    #>
    param(
        # potential input lines
        [Alias('Text')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'fromPipe')]
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'fromParam')]
        [string[]]$InputLines,

        [ArgumentCompletions(
            "'\r?\n'",
            "'\n'",
            "';'",
            "','",
            "'='"
        )]
        [Parameter(Position = 0, ParameterSetName = 'fromPipe')]
        [Parameter(Position = 1, ParameterSetName = 'fromParam')]
        [string]$SplitPattern = '\r?\n' # maybe it can be non-mandatory
    )
    process {
        foreach ($line in $InputLines) {
            # more performant string builder
            # $sb = [Text.StringBuilder]::new($Line)
            $Line -split $SplitPattern
        }
    }
}

function StrFormat-Replace {
    <#
    .notes
        refactor will have
        fn 'StrFormat-NormalizeLines'
        call this:

            PS> StrFormat-Replace '\r?\n', "`n"

    #>
    # [NotYetImplementedAttibute('reason: abcd')]
    [CmdletBinding()]
    param()
    throw "NYI: but this will be part of 'StrFormat-NormalizeLines' refactor"

}
function StrFormat-NormalizeLines {
    <#
    .SYNOPSIS
        normalize line endings
    .notes
        first:
            - [ ] generalize, then the impl. will invoke
                PS> StrFormat-Replace '\r?\n', "`n"

        future: perhaps split command, sometimes
            - [ ] replace as steppable pipe,
            - [ ] verses merge all then replace

            and whether the final value should be split string or not
            - [ ] test on giant strings, to discover if anything is super anti-performant.
    #>
    [OutputType('System.String')]
    param(
        [string[]]
        $InputLines

    )
    begin {
        Write-Warning "NOT FINISHED $PSCommandPath"
        # [Text.StringBuilder]$StringBuilder = [String]::Empty
        [Text.StringBuilder]$StringBuilder = ''
    }
    process {

        foreach ($Line in $Lines) {
            "StrFormat-NormalizeLines: Line:`n    '$Line'" | Write-Debug
            $StrBuild.AppendLine($Line)
        }
    }
    end {
        $StrBuild.repl
    }
}
function StrJoin-Lines {
    <#
    .SYNOPSIS
        Pipe a list of something, join on newlines convert to an Unordered List, or list of checkboxes
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
        # 'UL',
        # 'join.UL'
    )]
    param(
        #         # list of objects/strings to add
        #         [AllowEmptyCollection()]
        #         [AllowEmptyString()]
        #         [AllowNull()]
        #         [Parameter(Mandatory, ValueFromPipeline)]
        #         [string[]]$InputObject,

        #         # todo: Make custom arg completer
        #         # with parameter, so I can say 'use set X'
        #         # like 'arrows', or 'bars', or 'checkbox'
        #         [ArgumentCompletions(
        #             '•', '-', '‣',
        #             '[ ]', '[x]',
        #             '→', '☑️', '✅', '✔', '❌', '⛔', '⚠', '✔', '🧪', '📌', '👍', '👎'
        #         )]

        #         # sets bullet types, but if overriden in -Options, Options has priority
        #         [string]$BulletStr = '-',
        #         [ArgumentCompletions(
        #             '@{ ULHeader = (hr 0) ; ULFooter  = (hr 0); }',
        # @'
        # @{ ULHeader =  @( (hr 1) ; Label "Newest Files" "c:/temp"  ) | Join-String ; ULFooter  = (hr 0); }
        # '@, #-replace '\r?', '',
        # # @'
        # # @{  todo: Can I use the -replace operator, acting as a const expression?
        # #     ULHeader =  @( (hr 1) ; Label "Newest Files" "c:/temp"  ) | Join-String
        # #     ULFooter  = (hr 0);
        # # }
        # # '@, #-replace '\r?', '',
        #             '@{ BulletStr = "•" }'
        #         )]
        [hashtable]$Options = @{}
    )
    begin {
        throw "NYI: $PSCommandPath"
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
$script:__moduleExists ??= @{
    'ClassExplorer' = [bool](Get-Module 'ClassExplorer')
}
