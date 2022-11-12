using namespace System.Collections.Generic


#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Compare-StringSet'
        'experiment.newSet' # '.newSet'
    )
    $publicToExport.alias += @(
        'Set->CompareString' # 'Compare-StringSet'
        '.newSet' # 'experiment.newSet'
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

function experiment.newSet {
    # macro for a fresh instance
    # there's probably an easier way using .clone() but it didn't appear to work at the time
    [Alias('.newSet')]        
    [CmdletBinding()]
    param(
        # SHould I coerce nulls into an empty set? yes.
        # [ValidateNotNu()]
        [Parameter(Mandatory)]
        [string[]]$InputList,
        
        # default compares
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
    $cmp = $ComparerKind ?? ([StringComparer]::InvariantCultureIgnoreCase)

    if ( $PSBoundParameters.ContainsKey('ComparerKind') ) {
        [Collections.Generic.HashSet[String]]::new( [string[]]$InputList, $cmp )            
    }
    else {
        [Collections.Generic.HashSet[String]]::new( [string[]]$InputList )
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
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.predicate-1?view=net-7.0
    .NOTES
        Future:
            add custom [StringComparer] to enable **Smart Case Sensitive** 

        Add Custom formatData     
            When empty column format string as '∅'
            intersect as ..
            union ∪
            '∉' etc



        other functions:
            .ctor, Add, Clear, Comparer, Contains, CopyTo, Count, CreateSetComparer, EnsureCapacity, Enumerator, ExceptWith, GetEnumerator, GetObjectData, IntersectWith, IsProperSubsetOf, IsProperSupersetOf, IsSubsetOf, IsSupersetOf, OnDeserialization, Overlaps, Remove, RemoveWhere, SetEquals, SymmetricExceptWith, TrimExcess, TryGetValue, UnionWith
        where-predicates
            https://learn.microsoft.com/en-us/dotnet/api/system.predicate-1?view=net-7.0        
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
        [ValidateNotNull()]
        [Parameter(Mandatory)]
        [string[]]$ListA,

        # second group of strings to compare
        [Alias('Str2')]
        [ValidateNotNull()]
        [Parameter(Mandatory)]
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
    if($Sorted) { throw "NYI" }
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
        # https://en.wikipedia.org/wiki/Symmetric_relation
        # https://en.wikipedia.org/wiki/Set_theory

        [System.StringComparer]$ComparerKind = $ComparerKind # ?? "[`u{2400}]"
        
        [ValidateNotNull()]
        [Collections.Generic.List[Object]]$OriginalSetA = @()

        [ValidateNotNull()]
        [Collections.Generic.List[Object]]$OriginalSetB = @()

        
        <#
        todo: technically needs to be insensitive to ensure preserving original
        will it break, or be cleaner to have the list for original values
        instead of [StringComparer]::InvariantCultureIgnoreCase
        was:
                # [Collections.Generic.HashSet[String]]::new( $OriginalSetA ),
                # [Collections.Generic.HashSet[String]]::new( $OriginalSetB ),
        vs
        #>


        [Hashtable]$Meta = @{}

#         [string] PrettyPrint () { 
# $template = @'
# union A ∪ B 
# intersection A ∩ B
#     If A ∩ B = ∅, then A and B are said to be disjoint.

# set difference A \ B (also written A − B)
# symmetric difference A Δ B is

# symmetric difference A Δ B is the set of all things that belong to A or B but not both. One has

#     A Δ B == (A \ B) u (B \ A)

# cartesian product A × B is the set of all ordered pairs (a,b) such that a is an element of A and b is an element of B.
# '@
#             return $template
#         }

    }
    function _newSet {
        # macro for a fresh instance
        # there's probably an easier way using .clone() but it didn't appear to work at the time
        [OutputType('System.Collections.Generic.HashSet[String]]')]
        [CmdletBinding()]
        param( 
            [Parameter(Mandatory)]
            [string[]]$InputList,

            [AllowNull()]
            [Parameter()]
            [ArgumentCompletions(
                '([StringComparer]::CurrentCulture)',
                '([StringComparer]::CurrentCultureIgnoreCase)',
                '([StringComparer]::Ordinal)',
                '([StringComparer]::OrdinalIgnoreCase)',
                '([StringComparer]::InvariantCulture)',
                '([StringComparer]::InvariantCultureIgnoreCase)'
            )]
            [System.StringComparer]$ComparerKind
            # default compares
        )
        $cmp = $ComparerKind # ?? Actually, maybe *do* throw ojn invalid comparer

        if ($ComparerKind ) {
            [Collections.Generic.HashSet[String]]::new( [string[]]$InputList, $cmp )            
        }
        else {
            [Collections.Generic.HashSet[String]]::new( [string[]]$InputList )
        }

    }

    $splatNew = @{
        Comparer = $ComparerKind
    }
    $results = [StringSetComparisonResult]@{
        OriginalSetA = $ListA
        OriginalSetB = $ListB
    }
    # Note: without strongly typing, "_newSet" returns wrong types
    # I'm not exactly sure why , because the return statement is literally a constructor
    [ValidateNotNull()]
    [Collections.Generic.HashSet[String]]$SetA = _newSet @splatNew $ListA

    [ValidateNotNull()]
    [Collections.Generic.HashSet[String]]$SetB = _newSet @splatNew $ListB
   
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

    $results.Meta = @{
        Overlaps           = $SetA.Overlaps( $SetB )
        SetEquals          = $SetA.SetEquals( $SetB )          
        IsSubsetOf         = $SetA.IsSubsetOf($SetB)
        IsProperSubsetOf   = $SetA.IsProperSubsetOf($SetB)
        IsSupersetOf       = $SetA.IsSupersetOf($SetB)
        IsProperSupersetOf = $SetA.IsProperSupersetOf($SetB)        
    }
    #     'ASubB?'         = $SetA.IsSubsetOf($SetB)
    # IsProperSubsetOf   = $SetA.IsProperSubsetOf($SetB)
    # IsSupersetOf       = $SetA.IsSupersetOf($SetB)
    # IsProperSupersetOf = $SetA.IsProperSupersetOf($SetB)
    # $SetA.

    # $SetA = _newSet @splatNew $ListA
    # $SetB = _newSet @splatNew $ListB

    [StringSetComparisonResult]$Results
}