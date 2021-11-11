
if ( $script:publicToExport) {

}
$script:publicToExport.function += @(
    'Get-NinVerb'
)
$script:publicToExport.alias += @(
    '_enumerateNinVerb'
)

function Get-NinVerb {
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
    [Alias('_enumerateNinVerb')]
    [cmdletbinding()]
    param(
        # include global/regulars?
        [Parameter()]
        [switch]$All
    )

    end {
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

