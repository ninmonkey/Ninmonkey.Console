using namespace System.Collections.Generic


#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Compare-StringSet'
    )
    $publicToExport.alias += @(
        'Set->CompareString' # 'Compare-StringSet'
    )
}

   $script:__uniMath = [ordered]@{
        EmptySet = '∅'
        ForAll = '∀'
        ThereExists = '∃'
        NotThereExists = '∄'

        ElementOf = '∉'
        ElementOf_Small = '∊'
        NotElementOf = '∉'

        ContainsMember = '∋'
        ContainsMember_Small = '∍'
        NotContainsMember = '∌'

        SummationN = '∑'
        MinusOrPlus = '∓'

        more = @{
            Shapes = @{
                Squares = '⊏⊐⊑⊒⊓⊔'
            }

            SubsetsOf = '⊁⊂⊃⊄⊅⊆⊇⊈⊉⊊⊋⊌⊍⊎'
            ShapeSquares = '⊏⊐⊑⊒⊓⊔'
            Some = '⊄⊅⊆⊇⊈⊉⊊⊋⊌⊍⊎⊏⊐⊑⊒⊓⊔⊕⊖⊗⊘⊙⊚⊛⊜⊝⊞⊟⊠⊡'
            FullBlock = '∀∁∂∃∄∅∆∇∈∉∊∋∌∍∎∏∐∑−∓∔∕∖∗∘∙√∛∜∝∞∟∠∡∢∣∤∥∦∧∨∩∪∫∬∭∮∯∰∱∲∳∴∵∶∷∸∹∺∻∼∽∾∿≀≁≂≃≄≅≆≇≈≉≊≋≌≍≎≏≐≑≒≓≔≕≖≗≘≙≚≛≜≝≞≟≠≡≢≣≤≥≦≧≨≩≪≫≬≭≮≯≰≱≲≳≴≵≶≷≸≹≺≻≼≽≾≿⊀⊁⊂⊃⊄⊅⊆⊇⊈⊉⊊⊋⊌⊍⊎⊏⊐⊑⊒⊓⊔⊕⊖⊗⊘⊙⊚⊛⊜⊝⊞⊟⊠⊡⊢⊣⊤⊥⊦⊧⊨⊩⊪⊫⊬⊭⊮⊯⊰⊱⊲⊳⊴⊵⊶⊷⊸⊹⊺⊻⊼⊽⊾⊿⋀⋁⋂⋃⋄⋅⋆⋇⋈⋉⋊⋋⋌⋍⋎⋏⋐⋑⋒⋓⋔⋕⋖⋗⋘⋙⋚⋛⋜⋝⋞⋟⋠⋡⋢⋣⋤⋥⋦⋧⋨⋩⋪⋫⋬⋭⋮⋯⋰⋱⋲⋳⋴⋵⋶⋷⋸⋹⋺⋻⋼⋽⋾⋿'
        }


    }



function Compare-StringSet {
    <#
    .synopsis
        quickly
    .example
        Compare-StringSet ('a'..'g') ('c'..'z')
        Compare-StringSet ('a'..'g') ('A'..'E')
    .example
        Compare-StringSet ('a'..'g') ('A'..'E') -Insensitive
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.hashset-1?view=net-6.0#hashset-and-linq-set-operations

    .NOTES
        other functions:
            .ctor, Add, Clear, Comparer, Contains, CopyTo, Count, CreateSetComparer, EnsureCapacity, Enumerator, ExceptWith, GetEnumerator, GetObjectData, IntersectWith, IsProperSubsetOf, IsProperSupersetOf, IsSubsetOf, IsSupersetOf, OnDeserialization, Overlaps, Remove, RemoveWhere, SetEquals, SymmetricExceptWith, TrimExcess, TryGetValue, UnionWith
    #>
    [Alias(
        'Set->CompareString'
    )]
    param(
        [string[]]$ListA,
        [string[]]$ListB,
        [switch]$Insensitive,
        $ComparerKind
        # [object]$ComparerFunc
        # [hashtable]$Options
    )
    <#
    todo: future:
        When empty column format string as '∅'
        intersect as ..
        union ∪
        '∉' etc
    #>
    class StringSetComparisonResult {
        [list[string]]$Intersect
        [list[string]]$RemainingLeft
        [list[string]]$RemainingRight
        [list[string]]$Union
    }
    $Config = @{
        Insensitive  = $Insensitive
        ComparerKind = $ComparerKind ?? [StringComparer]::InvariantCultureIgnoreCase
    }
    # wait-debugger

    $results = [ordered]@{}

    function _newSet {
        # macro for a fresh instance
        param( $InputList, $Comparer )
        $Comparer ??= $Config.ComparerKind = [StringComparer]::InvariantCultureIgnoreCase
        if($Config.Insensitive ) {
            [HashSet[string]]::new( $InputList )
        } else {
            [HashSet[string]]::new( $InputList, $Comparer )
        }

    }

    # example:
    # \
# [HashSet[String]]::new( [string[]]$letters, [StringComparer]::InvariantCultureIgnoreCase )
    # if($Insensitive) {
    #     $SetA = [HashSet[string]]::new(
    #         [string[]]$ListA,
    #         [StringComparer]::InvariantCultureIgnoreCase )
    #     $SetB = [HashSet[string]]::new(
    #         [string[]]$ListB,
    #         [StringComparer]::InvariantCultureIgnoreCase )
    # } else {
    #     $SetA = [HashSet[string]]::new( [string[]]$ListA)
    #     $SetB = [HashSet[string]]::new( [string[]]$ListB)
    # }
    $SetA = _newSet $ListA
    $SetB = _newSet $ListB

    $SetA.IntersectWith( $setB )
    $results['Intersect'] = $SetA

    $SetA = _newSet $ListA
    $SetB = _newSet $ListB

    # $SetA -notin $results.Intersect
    $results.'RemainingLeft' =  $SetA | ?{
        $results.'Intersect' -notcontains $_
    }
    $results.'RemainingRight' =  $SetB | ?{
        $results.'Intersect' -notcontains $_
    }

    $SetA = _newSet $ListA
    $SetB = _newSet $ListB

    $SetA.UnionWith( $SetB )
    $results.'Union' = $SetA


    [StringSetComparisonResult]$Results

    # [hashset[string]]::new( [string[]]('a', 'b')
}