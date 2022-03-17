
if ( $script:publicToExport) {
    $script:publicToExport.function += @(
        'Get-NinVerb'
        'Get-NinVerbName'
        'Get-NinVerbInfo'

    )
    $script:publicToExport.alias += @(
        '_enumerateNinVerb' # 'Get-NinVerb'
        '_enumerateNinVerbInfo' # 'Get-NinVerbInfo'



        '_enumerateNinVerbName' # Get-NinVerbName
        'Completions->NinVerbName' # Get-NinVerbName
    )
}

function Get-NinVerb {
    # minimal query, not like Get-NinVerbInfo

    [Alias('_enumerateNinVerb')]
    param()
    throw 'NYI : simplified =version of "Get-NinVerbInfo"'
}

function Get-NinVerbName {
    <#
    .synopsis
        enumerate filtered, custom verb names to only '->' verbs
    .example
        PS> Get-NinVerbName

            Color,Compare,Completions,Console,Copy,Dev,DevTool,Dive,Dump,Export,Filter,Find,fmt,From,Gh,Git,Help,Info,Inspect,Iter,Jq,New,Out,Peek,Pick,Pipe,Rand,Ref,Repl,Select,Set,Show,To,Uni,Web,Window,wt
    .example
        PS> $selected = Get-NinVerbName | Fzf -m

    .link
        Ninmonkey.Console\Get-NinVerb
    .link
        Ninmonkey.Console\Get-NinVerbName
    .link
        Ninmonkey.Console\Get-NinVerbInfo
    #>
    [Alias(
        '_enumerateNinVerbName',
        'Completions->NinVerbName'
    )]
    [OutputType('[String[]]')]
    param()

    Import-Module Dev.Nin, Ninmonkey.Console, Ninmonkey.Profile, Ninmonkey.PowerShell -ea continue -wa ignore
    | Out-Null

    $query = Get-Command -m (_enumerateMyModule)
    | Where-Object Name -Match '->'
    | ForEach-Object {
        $_.Name -split '->' | Select-Object -First 1
    } | Sort-Object -Unique

    return $query
}

function Get-NinVerbInfo {
    <#
    .synopsis
        Enumerate non-standard verbs (or aliases)
    .description
        Don't judge me. It's for my profile.
    .notes
        some of this is overlapping get commands
    .example
        PS> Get-NinVerb
    #>
    [Alias('_enumerateNinVerbInfo')]
    [cmdletbinding()]
    param(
        # include global/regulars?
        [Parameter()]
        [switch]$All
    )

    end {
        Import-Module Dev.Nin, Ninmonkey.Console, Ninmonkey.Profile, Ninmonkey.PowerShell -ea continue

        $gcm_enumMine = Get-Command -m (_enumerateMyModule) *
        | Where-Object CommandType -NE 'application'

        $meta = [ordered]@{



            # My Module Noun, Pwsh's def of noun
            BasicNouns      = $gcm_enumMine
            | ForEach-Object noun
            | Sort-Object -Unique

            # My Module Verb, Pwsh's def of verb
            BasicVerbs      = $gcm_enumMine
            | ForEach-Object Verb
            | Sort-Object -Unique

            # My module's "->" commands
            NinVerbCommands = $gcm_enumMine
            | Where-Object name -Match (ReLit '->')

            # mine where no '-' anywhere
            'NinWithout-'   = $gcm_enumMine
            | Where-Object name -NotMatch '-'

            # under/dunder score on name
            NinUnders       = $gcm_enumMine
            | ?Str -Begins '_' Name

            LegalVerbs      = Get-Verb
            | ForEach-Object Verb | Sort-Object -Unique
        }

        #$verbsLegal = Get-Verb | % Verb | sort -Unique
        $BasicVerbs = $gcm_enumMine
        | ForEach-Object Verb
        | Sort-Object -Unique
        $hlegal = [HashSet[string]]::new( [string[]]$meta.LegalVerbs )
        $hmine = [HashSet[string]]::new( [string[]]$meta.BasicVerbs )


        # $meta['BasicVerbs'] | str csv -Sort
        # | str prefix 'basicVerbs: ' | wi

        # $meta['NinVerbs'] | str csv -Sort
        # | str prefix 'basicNinVerbs: ' | wi

        # $meta['NinVerbs'] | str csv -Sort
        # | str prefix 'basicNinVerbs: ' | wi


        if ($true -or $All) {
            $meta += @{
                AllBasicNouns = Get-Command *
                | ForEach-Object noun
                | Sort-Object -Unique

                AllBasicVerbs = Get-Command *
                | ForEach-Object Verb
                | Sort-Object -Unique
            }
        }
        # different results depending on queries
        # Get-Command '*->*' | ? CommandType -NotIn @('Application')
        [pscustomobject]$meta

    }
}
