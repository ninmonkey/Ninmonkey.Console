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
        # https://en.wikipedia.org/wiki/Symmetric_relation
        # https://en.wikipedia.org/wiki/Set_theory

        

        [System.StringComparer]$ComparerKind = $ComparerKind # ?? "[`u{2400}]"
        # todo: technically needs to be insensitive to ensure preserving original
        # close enough for this sketch
        [Collections.Generic.HashSet[String]]$OriginalSetA
        [Collections.Generic.HashSet[String]]$OriginalSetB

        [Hashtable]$Meta = @{}

        [string] PrettyPrint (  ) {
            # return    ''               

            # https://www.compart.com/en/unicode/category/Sm
            $Uni_Sources = @{
                # more to get
                'equalityTesting' = 0x223c..0x2281
            }
            $Uni = @{
                'Equal'                   = @{
                    'IsIdentical'       = "`u{2261}"
                    'NotIsIdentical'    = "`u{2262}"
                    'StrictlyEqual'     = "`u{2263}"
                    'EqualByDefinition' = "`u{225D}"
                    'QuestionedEqualTo' = "`u{225F}"
                    'NotEqual'          = "`u{2260}"
                    'ApproxEqualTo'     = "`u{2245}"            
                }
                # 'MathSymbol' = @{
                #     Therefore = ''
                    
                # }
                'Therefore'               = "`u{2234}"
                'Because'                 = "`u{2235}"
                Set                       = @{
                    ForAll              = "`u{2200}"
                    Complement          = "`u{2201}"
                    ThereExists         = "`u{2203}"
                    ThereDoesNotExist   = "`u{2204}"
                    EmptySet            = "`u{2205}"
                    ElementOf           = "`u{2208}"
                    NotElementOf        = "`u{2209}"
                    Empty               = "`u{2205}"
                    ContainsAsMember    = "`u{220b}"
                    NotContainsAsMember = "`u{220c}"                    
                }
                Operator                  = @{
                    True           = "`u{22a6}"                    
                    Assertion      = "`u{22a8}"                    
                    Logical        = @{
                        And = "`u{2227}"
                        Or  = "`u{2228}"
                    }
                    Ring           = "`u{2218}"
                    Bullet         = "`u{2219}"
                    Intersection   = "`u{2229}"
                    Union          = "`u{222a}"
                    
                    XOR            = "`u{22bb}"
                    NAnd           = "`u{22bc}"
                    Nor            = "`u{22bd}"

                    LeftOuterJoin  = "`u{27d5}"
                    RightOuterJoin = "`u{27d6}"
                    FullOuterJoin  = "`u{27d7}"


                }
                
                # todo: refactor: pipescript grab range and inline symbols
                EmptySet                  = '∅'

                Subset                    = "`u{2282}" # 
                Superset                  = "`u{2283}" # 
                NotSubset                 = "`u{2284}" # 
                NotSuperSet               = "`u{2285}" # 
                SubsetOrEqual             = "`u{2286}" # 
                SupersetOrEqual           = "`u{2287}" # 
                NeitherSubsetNorEqual     = "`u{2288}" # 
                NeitherSuperSetNorEqual   = "`u{2289}" # 
                 
                SubsetOfWithNotEqual      = "`u{228a}" # 
                SupersetOfWithNotEqual    = "`u{228b}" # 
                NeitherSuperSetOfNorEqual = "`u{228c}" # 


            }
            function _addPair {
                param(
                    [Parameter(mandatory)][string]$KeyStr,
                    [Parameter(mandatory)][string]$ValueStr
                )
                $meta[ $KeyStr ] = $ValueStr
            }
            $SetA = $This.OriginalSetA    
            $SetB = $This.OriginalSetB
            $meta = @{
                Overlaps           = $SetA.Overlaps( $SetB )
                SetEquals          = $SetA.SetEquals( $SetB )          
                IsSubsetOf         = $SetA.IsSubsetOf($SetB)
                IsProperSubsetOf   = $SetA.IsProperSubsetOf($SetB)
                IsSupersetOf       = $SetA.IsSupersetOf($SetB)
                IsProperSupersetOf = $SetA.IsProperSupersetOf($SetB)        
            }
            _addPair -KeyStr @(
                'a {0} b' -f @( $Uni.Subset )
            ) -ValueStr @(
                $SetA.IsSubsetOf( $SetB )
            )
            _addPair -KeyStr @(
                'b {0} a' -f @( $Uni.Subset )
            ) -ValueStr @(
                $SetB.IsSubsetOf( $SetA )
            )
            _addPair -KeyStr @(
                'a {0} b' -f @( $Uni.IsProperSubsetOf )
            ) -ValueStr @(
                $SetA.IsProperSubsetOf( $SetB )
            )
            _addPair -KeyStr @(
                'b {0} a' -f @( $Uni.Subset )
            ) -ValueStr @(
                $SetB.IsSubsetOf( $SetA )
            )
            # IsProperSubsetOf   = $SetA.IsProperSubsetOf($SetB)
            # IsSupersetOf       = $SetA.IsSupersetOf($SetB)
            # IsProperSupersetOf = $SetA.IsProperSupersetOf($SetB)

            # $keyStr = 'a {0} b' -f @(
            #     $Uni.Subset
            # )
            # $valueStr = '{0}' -f @(
            #     $SetA.IsSubsetOf( $SetB )                                
            # )
            # $meta[$KeyStr] = $valueStr

            $meta | Format-List -Force | Out-String | Write-Host
            return [string]($Meta | Format-List -Force | Out-String | Join-String)
            # 'ASubB?' = $SetA.IsSubsetOf($SetB)

            if ($Sensitive) { 
                $ComparerKind = [StringComparer]::CurrentCulture
            }
            if ($Insensitive) { 
                $ComparerKind = [StringComparer]::CurrentCultureIgnoreCase
            }
            $results = [StringSetComparisonResult]@{
                OriginalSetA = $ListA
                OriginalSetB = $ListB
            }
        }
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