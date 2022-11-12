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
    EmptySet             = '∅'
    ForAll               = '∀'
    ThereExists          = '∃'
    NotThereExists       = '∄'

    ElementOf            = '∉'
    ElementOf_Small      = '∊'
    NotElementOf         = '∉'

    ContainsMember       = '∋'
    ContainsMember_Small = '∍'
    NotContainsMember    = '∌'

    SummationN           = '∑'
    MinusOrPlus          = '∓'

    more                 = @{
        Shapes       = @{
            Squares = '⊏⊐⊑⊒⊓⊔'
        }

        SubsetsOf    = '⊁⊂⊃⊄⊅⊆⊇⊈⊉⊊⊋⊌⊍⊎'
        ShapeSquares = '⊏⊐⊑⊒⊓⊔'
        Some         = '⊄⊅⊆⊇⊈⊉⊊⊋⊌⊍⊎⊏⊐⊑⊒⊓⊔⊕⊖⊗⊘⊙⊚⊛⊜⊝⊞⊟⊠⊡'
        FullBlock    = '∀∁∂∃∄∅∆∇∈∉∊∋∌∍∎∏∐∑−∓∔∕∖∗∘∙√∛∜∝∞∟∠∡∢∣∤∥∦∧∨∩∪∫∬∭∮∯∰∱∲∳∴∵∶∷∸∹∺∻∼∽∾∿≀≁≂≃≄≅≆≇≈≉≊≋≌≍≎≏≐≑≒≓≔≕≖≗≘≙≚≛≜≝≞≟≠≡≢≣≤≥≦≧≨≩≪≫≬≭≮≯≰≱≲≳≴≵≶≷≸≹≺≻≼≽≾≿⊀⊁⊂⊃⊄⊅⊆⊇⊈⊉⊊⊋⊌⊍⊎⊏⊐⊑⊒⊓⊔⊕⊖⊗⊘⊙⊚⊛⊜⊝⊞⊟⊠⊡⊢⊣⊤⊥⊦⊧⊨⊩⊪⊫⊬⊭⊮⊯⊰⊱⊲⊳⊴⊵⊶⊷⊸⊹⊺⊻⊼⊽⊾⊿⋀⋁⋂⋃⋄⋅⋆⋇⋈⋉⋊⋋⋌⋍⋎⋏⋐⋑⋒⋓⋔⋕⋖⋗⋘⋙⋚⋛⋜⋝⋞⋟⋠⋡⋢⋣⋤⋥⋦⋧⋨⋩⋪⋫⋬⋭⋮⋯⋰⋱⋲⋳⋴⋵⋶⋷⋸⋹⋺⋻⋼⋽⋾⋿'
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
        Compare-StringSet ('a'..'g') ('A'..'E') -ci
    .example
        $compareSetSplat = @{
            ListA = 'a', 'A', 'e', 'cat', '3', 'CaT'
            ListB = 'e', 'F', 'F', 'z', 3, 'CAT'
            # ErrorAction = 'ignore' 
        }

        $FormatEnumerationLimit = 30
        Compare-StringSet @compareSetSplat -ea ignore
        Compare-StringSet @compareSetSplat -ea ignore -ComparerKind ([StringComparer]::CurrentCultureIgnoreCase)
        Compare-StringSet @compareSetSplat -ea ignore -ComparerKind ([StringComparer]::Ordinal)
        $FormatEnumerationLimit = 4
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.hashset-1?view=net-6.0#hashset-and-linq-set-operations
    .LINK
        https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.hashset-1?view=net-7.0
    .NOTES
        Future:
            add custom [StringComparer] to enable **Smart Case Sensitive** 

        Add Custom formatData     
            When empty column format string as '∅'
            intersect as ..
            union ∪
            '∉' etc



        other functions:
            .ctor, Add, Clear, Compraer, Contains, CopyTo, Count, CreateSetComparer, EnsureCapacity, Enumerator, ExceptWith, GetEnumerator, GetObjectData, IntersectWith, IsProperSubsetOf, IsProperSupersetOf, IsSubsetOf, IsSupersetOf, OnDeserialization, Overlaps, Remove, RemoveWhere, SetEquals, SymmetricExceptWith, TrimExcess, TryGetValue, UnionWith
        LINQ:
            Union, Intersect, Except, Distinct
            <https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.hashset-1?view=net-7.0#hashset-and-linq-set-operations>    
    #>
    [Alias(
        'Set->CompareString'
    )]
    [CmdletBinding()]
    [OutputType('Object', 'StringSetComparisonResult')]
    param(
        # First group of strings to compare
        [Alias('Str1')]
        [string[]]$ListA,

        # second group of strings to compare
        [Alias('Str2')]
        [string[]]$ListB,

        # sugar to choose current insensitive compare
        [Alias('ci')]
        [switch]$Insensitive,
        # sugar to choose current sensitive compare
        [Alias('cs')]
        [switch]$Sensitive,

        # Sort resulting sets
        [switch]$Sorted,

        # If none is specified, then the inner 
        # func _newSet uses the implicit constructor
        [ArgumentCompletions(
            '([StringComparer]::CurrentCulture)',
            '([StringComparer]::CurrentCultureIgnoreCase)',
            '([StringComparer]::Ordinal)',
            '([StringComparer]::OrdinalIgnoreCase)',
            '([StringComparer]::InvariantCulture)',
            '([StringComparer]::InvariantCultureIgnoreCase)'
        )]
        [System.StringComparer]$ComparerKind
    )
    <#
    todo: future:
        When empty column format string as '∅'
        intersect as ..
        union ∪
        '∉' etc

        see also: [System.StringComparer]::InvariantCultureIgnoreCase

    other members/methods
        Add
        Clear
        Comparer
        Contains
        CopyTo
        Count
        CreateSetComparer
        EnsureCapacity
        Enumerator
        ExceptWith
        GetEnumerator
        GetObjectData
        IntersectWith
        IsProperSubsetOf
        IsProperSupersetOf
        IsSubsetOf
        IsSupersetOf
        OnDeserialization
        Overlaps
        Remove
        RemoveWhere
        SetEquals
        SymmetricExceptWith
        TrimExcess
        TryGetValue
        UnionWith
    #>    
    class StringSetComparisonResult {
        [Collections.Generic.HashSet[String]]$Intersect = @('?')
        [Collections.Generic.HashSet[String]]$Union = @('?')
        [Collections.Generic.HashSet[String]]$RemainingLeft = @('?') # 
        [Collections.Generic.HashSet[String]]$RemainingRight = @('?')    
        [Collections.Generic.HashSet[String]]$SymmetricDiff = @('?')

        # subsets
        # 

        

        [System.StringComparer]$ComparerKind = $ComparerKind # ?? "[`u{2400}]"
        [Collections.Generic.HashSet[String]]$OriginalListA
        [Collections.Generic.HashSet[String]]$OriginalListB
    }
    if ($Sensitive) { 
        $ComparerKind = [StringComparer]::CurrentCulture
    }
    if ($Insensitive) { 
        $ComparerKind = [StringComparer]::CurrentCultureIgnoreCase
    }
    $results = [StringSetComparisonResult]@{
        OriginalListA = $ListA
        OriginalListB = $ListB
    }

    function _newSet {
        # macro for a fresh instance
        # there's probably an easier way using .clone() but it didn't appear to work at the time
        param( [string[]]$InputList, $Comparer )
        $cmp = $Comparer ?? ([StringComparer]::InvariantCultureIgnoreCase)

        if ($Comparer ) {
            [Collections.Generic.HashSet[String]]::new( [string[]]$InputList, $cmp )            
        }
        else {
            [Collections.Generic.HashSet[String]]::new( [string[]]$InputList )
        }

    }

    $splatNew = @{
        Comparer = $ComparerKind
    }
    
    # Note: without strongly typing, "_newSet" returns wrong types
    # I'm not exactly sure why , because the return statement is literally a constructor
    [ValidateNotNull()]
    [Collections.Generic.HashSet[String]]$SetA = _newSet @splatNew $ListA

    [ValidateNotNull()]
    [Collections.Generic.HashSet[String]]$SetB = _newSet @splatNew $ListB

    $SetA.Intersect( $setB )
    $results['Intersect'] = $SetA

    $SetA = _newSet @splatNew $ListA
    $SetB = _newSet @splatNew $ListB
    
    # $SetA -notin $results.Intersect
    $results.'RemainingLeft' = '?' 
    # $SetA | ?{ $results.'Intersect' -notcontains $_ }
    $results.'RemainingRight' = '?'
    #$SetB | ?{ $results.'Intersect' -notcontains $_ }
    
    $SetA = _newSet @splatNew $ListA
    $SetB = _newSet @splatNew $ListB
    $results.Intersect = $SetA.IntersectWith( $SetB ) && $SetA

    $SetA = _newSet @splatNew $ListA
    $SetB = _newSet @splatNew $ListB
    $results.RemainingLeft = $SetA.ExceptWith( $SetB ) && $SetA

    $SetA = _newSet @splatNew $ListA
    $SetB = _newSet @splatNew $ListB
    $results.RemainingRight = $SetB.ExceptWith( $SetA ) && $SetB

    $SetA = _newSet @splatNew $ListA
    $SetB = _newSet @splatNew $ListB
    $results.Union = $SetA.UnionWith( $SetB ) && $SetA
    
    $SetA = _newSet @splatNew $ListA
    $SetB = _newSet @splatNew $ListB
    $results.SymmetricDiff = $SetA.SymmetricExceptWith( $SetB ) && $SetA

    $States = @{
        Overlaps = $SetA.Overlaps( $SetB )
        
    }

    # $SetA = _newSet @splatNew $ListA
    # $SetB = _newSet @splatNew $ListB

    [StringSetComparisonResult]$Results
}