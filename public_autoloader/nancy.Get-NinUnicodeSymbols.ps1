# using namespace System.Collections.Generic
# return


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


# https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.hashset-1?view=net-6.0#hashset-and-linq-set-operations


function PrettyPrint (  ) {
    Write-Warning 'nyi'
    Write-Error 'nyi: uni symbols'
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

    # $keyStr = 'a {0} b' -f @(
    #     $Uni.Subset
    # )
    # $valueStr = '{0}' -f @(
    #     $SetA.IsSubsetOf( $SetB )                                
    # )
    # $meta[$KeyStr] = $valueStr

    # # 'ASubB?' = $SetA.IsSubsetOf($SetB)

    # if ($Sensitive) { 
    #     $ComparerKind = [StringComparer]::CurrentCulture
    # }
    # if ($Insensitive) { 
    #     $ComparerKind = [StringComparer]::CurrentCultureIgnoreCase
    # }
}

