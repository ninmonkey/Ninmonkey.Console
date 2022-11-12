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
        [Collections.Generic.List[String]]$Intersect
        [Collections.Generic.List[String]]$RemainingLeft
        [Collections.Generic.List[String]]$RemainingRight
        [Collections.Generic.List[String]]$Union
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
            [Collections.Generic.List[String]]::new( $InputList )
        } else {
            [Collections.Generic.List[String]]::new( $InputList, $Comparer )
        }

    }

    # example:
    # \
# [Collections.Generic.List[String]]::new( [string[]]$letters, [StringComparer]::InvariantCultureIgnoreCase )
    # if($Insensitive) {
    #     $SetA = [Collections.Generic.List[String]]::new(
    #         [string[]]$ListA,
    #         [StringComparer]::InvariantCultureIgnoreCase )
    #     $SetB = [Collections.Generic.List[String]]::new(
    #         [string[]]$ListB,
    #         [StringComparer]::InvariantCultureIgnoreCase )
    # } else {
    #     $SetA = [Collections.Generic.List[String]]::new( [string[]]$ListA)
    #     $SetB = [Collections.Generic.List[String]]::new( [string[]]$ListB)
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

    # [Collections.Generic.List[String]]::new( [string[]]('a', 'b')
}