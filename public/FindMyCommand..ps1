function Find-MyCommand {
    <#
    .synopsis
        sketch, not ready.
    #>
    h1 'sketch'
    $queryTerm = '*prop*', '*object*', '*hashtable*'
    $query = Get-Command -m (_enumerateMyModule) $queryTerm



    h1 'details'
    $query
    | Where-Object { $_.CommandType -notin @('Alias', 'Application') }
    | Sort-Object Source, Name
    | Get-Random -Count 20
    | First 3
    | s -ExcludeProperty Definition, ScriptBlock
    | Out-Null

    h1 'sort types'
    $query | Get-Random -Count 40
    | Sort-Object Verb, Name
    | Out-Null


    & {
        $randTest1 = $query | Get-Random -Count 40
        h1 'type1: verb centric'
        $randTest1 | Sort-Object Verb, Name, Source
        | Format-Table Name, Source -GroupBy Verb -AutoSize
    
        h1 'type2: Source, name'
        $randTest1
        | Sort-Object Source, Name, Verb
        | Format-Table Name, Verb -GroupBy Source -AutoSize
    }

    '*filter->*', '*from->*', '*to->*' | ForEach-Object { 
        Get-Command -m (_enumerateMyModule) $_
        hr 
    }


}