#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Format-ShortTypename'
        'Format-UnorderedList' # 'Join.UL'
        'Format-ShortSciTypeName'
    )
    $publicToExport.alias += @(
        'shortTypeName' # 'Format-ShortTypename'
        # 'UL'
        'Join.UL' # 'Format-UnorderedList'
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
        'Join.UL'
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
            '•', '-',
            '[ ]', '[x]',
            '→', '☑️', '✅', '✔', '❌', '⛔', '⚠', '✔', '🧪', '📌', '👍', '👎',
            '⦿', '‣', '•', '⁃', '⁌', '◦'
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
$script:__moduleExists = @{ # cached for: Format-ShortSciTypeName
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

$script:__ninNamespaceMapping = @{
    'PoshCode.Pansies' = 'Pansies'
    'System.Xml.Linq' = 'xml.Linq'
    'System.Linq' = 'Linq'
    'Newtonsoft.Json' = 'newtjs'
    'Runtime.InteropServices' = 'ri'
    'Reflection' = 'r'
    'Text.RegularExpressions' = 't.re' # 're' or 't.re'
    'Text' = 't'
    'Runtime' = 'run' # 'run' or 'rt'
    'Runspaces' = 'runs'
    'Xml.Schema' = 'schema.'
    'Windows' = 'win'
    'Threading' = 't' # '' or 't'
    'Windows.Networking.Sockets' = 'win.sock'
    'Windows.Media' = 'win.media'
    'Windows.Networking' = 'win.net'
    'Windows.Globalization' = 'global' # 'cult' or 'global'
    'System.Management.Automation' = 'sma'
    'System.Security.Cryptography' = 'crypto'
    'Microsoft.PowerShell.Commands' = 'pwsh.cmds'
    'Microsoft.ApplicationInsights' = 'app.insight'
    'Microsoft.CodeAnalysis' = 'code.analysis'
    'ABI.Windows.Networking' =  'abi.net'
    'ABI.Windows.Globalization' = 'abi.global'
    'ABI.Windows.Devices.Bluetooth' = 'abi.bluetooth'
    'System.Diagnostics' = 'diag'
    'System.Net.NetworkInformation' = 'net.info'
    'System.Xml.Xsl' = 'xsl'
    'System.Management.Automation.Configuration'        = 'sma.Configuration'
    'System.Management.Automation.Host'                 = 'sma.Host'
    'System.Management.Automation.Internal'             = 'sma.Internal'
    'System.Management.Automation.Language'             = 'sma.Language'
    'System.Management.Automation.Provider'             = 'sma.Provider'
    'System.Management.Automation.PSTasks'              = 'sma.PSTasks'
    'System.Management.Automation.Remoting'             = 'sma.Remoting'
    'System.Management.Automation.Remoting.Client'      = 'sma.Remoting.Client'
    'System.Management.Automation.Remoting.Internal'    = 'sma.Remoting.Internal'
    'System.Management.Automation.Remoting.WSMan'       = 'sma.Remoting.WSMan'
    'System.Management.Automation.Runspaces'            = 'sma.Runspaces'
    'System.Management.Automation.Security'             = 'sma.Security'
    'System.Management.Automation.Subsystem'            = 'sma.Subsystem'
    'System.Management.Automation.Subsystem.DSC'        = 'sma.Subsystem.DSC'
    'System.Management.Automation.Subsystem.Prediction' = 'sma.Subsystem.Prediction'
    'System.Management.Automation.Tracing'              = 'sma.Tracing'
} | %{ $_.GetEnumerator() } | sort-Object { $_.Key.Length } -Desc

if($True -and 'exportGlobal') {
    $global:__ninNamespaceMapping = $script:__ninNamespaceMapping
}

function Format-ShortTypeName {
    <#
    .EXAMPLE
        PS> [System.Management.Automation.VerboseRecord] | shortTypeName

            [VerboseRecord]
    .notes
        to find type names, try:

            find-type -Namespace *xml* | Format-ShortTypeName | sls 'xml' -AllMatches

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
    .EXAMPLE
        PS> gci .   | xa.TypeOf -FormatMode TypeInfo
                    | Sort-Object -Unique | Format-ShortTypeName

        # output:

        [IO.DirectoryInfo]
        [IO.FileInfo]
    .notes
        render-* implies ansi colors

    .link
        Ninmonkey.Console\Format-ShortTypeName
    .link
        Ninmonkey.Console\Render-ShortTypeName

    #>
    [Alias(
        'shortTypeName'
    )]
    [CmdletBinding()]
    param(
        [AllowNull()]
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject,

        # using '$script:__ninNamespaceMapping'
        [Alias('UsingMapping')][switch]$UsingCustomMapping,
        # replace namespaces with something short, not nothing
        [switch]$UsingNamespaceAliases
    )
    process {
        if($null -eq $InputObject){ return 'TrueNull' }
        $IsRawString = $InputObject -is 'string'
        if($IsRawString) {
            if($InputObject.Length -eq 0) {
                return '[String]::Empty'
            }
        }

        $nameString = ''
        if ($InputObject -is 'type') {
            $Target = $InputObject
            $nameString = $Target.FullName
        } elseif($InputObject -isnot 'string' ) {
            $Target = $InputObject.GetType()
            $nameString = $Target.FullName
        } else {
            $nameString = $InputObject
        }
        $accum = $nameString
        Join-String -op 'initial input ' -single -inp $accum | Write-Debug

        if($UsingCustomMapping) {
            foreach($pair in $script:__ninNamespaceMapping.GetEnumerator()) {
                $Pair.Key, $Pair.Value | Join-String -op '   try name: ' | write-debug
                [string]$regexKey = [Regex]::escape( $Pair.Key )
                if($accum -match $regexKey) {
                    $toBreak  = $true
                }
                $accum = $accum -replace $regexKey, $Pair.Value
                Join-String -op '   set value := ' -inp $accum | Write-Debug
                if($ToBreak){
                    break
                }
            }
            Join-String -op 'final value ' -inp $accum | Write-Debug
            Join-String -op '[' -os ']' -Input $accum
            return
        }

        if( -not $UsingNamespaceAliases) {
            $accum = $accum -replace
                '^(System\.)?(Management.Automation\.)?', '' -replace
                '^PoshCode\.Pansies', 'Pansies'
        } else {
            $accum = $accum -replace
                '^(System\.)?(Management.Automation\.)?', 'sma.' -replace
                '^PoshCode\.Pansies', 'Pansies'

        }
        Join-String -op 'final value ' -inp $accum | Write-Debug
        Join-String -op '[' -os ']' -Input $accum


        # if ($InputObject -is 'type') {
        #     $Target = $InputObject
        # } else {
        #     $Target = $InputObject.GetType()
        # }

        # $Target.FullName -replace '^System\.(Management.Automation\.)?', '' -replace '^PoshCode\.Pansies', 'Pansies'
        # | Join-String -op '[' -os ']'
    }
}
