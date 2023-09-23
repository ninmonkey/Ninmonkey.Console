
if ( $script:publicToExport) {
    $script:publicToExport.function += @(
        'New-NinStringComparer'
    )
    $script:publicToExport.alias += @(
        'Nin.StringComparer'
    )
}

function New-NinStringComparer {
    <#
    .SYNOPSIS
        quickly call a string comparison, or return the comparer type as a instance
    .NOTES
        future: add support for CultureInfo options
    .EXAMPLE
        Dotils.New-StringComparer 'a' 'A' OrdinalIgnoreCase, InvariantCulture  |Ft -AutoSize

            CompareName       CompareFunc                      Left Right Result
            -----------       -----------                      ---- ----- ------
            OrdinalIgnoreCase System.OrdinalIgnoreCaseComparer a    A          0
            InvariantCulture  System.CultureAwareComparer      a    A         -1
    .EXAMPLE
        Dotils.New-StringComparer -left 'a' -Right 'A' -StringComparerKind InvariantCultureIgnoreCase, InvariantCulture

    .EXAMPLE
        # Passthru returns the comparers

        $q = Dotils.New-StringComparer -All -PassThru
        $q.ForEach({ $_.Compare('a', 'A') }) | Join.Csv

        # prints:
            -1, 0, -1, 0, 32, 0

        $q.ForEach({ $_ | Format-ShortTypeName }) | sort -Unique | Join.csv

        # prints:
            [CultureAwareComparer], [OrdinalCaseSensitiveComparer], [OrdinalIgnoreCaseComparer]

    .EXAMPLE
        Dotils.New-StringComparer -left 'a' -Right 'A' -All

        CompareName                CompareFunc                         Left Right Result
        -----------                -----------                         ---- ----- ------
        InvariantCulture           System.CultureAwareComparer         a    A         -1
        InvariantCultureIgnoreCase System.CultureAwareComparer         a    A          0
        CurrentCulture             System.CultureAwareComparer         a    A         -1
        CurrentCultureIgnoreCase   System.CultureAwareComparer         a    A          0
        Ordinal                    System.OrdinalCaseSensitiveComparer a    A         32
        OrdinalIgnoreCase          System.OrdinalIgnoreCaseComparer    a    A          0
    #>
    [Alias('Nin.StringComparer')]
        param(
            [AllowEmptyString()]
            [Parameter(Position=0)][string]$LeftInput,

            [AllowEmptyString()]
            [Parameter(Position=1)][string]$RightInput,


        [Alias('CompareAs')]
        [Parameter(Position = 2)]
        [ArgumentCompletions(
            # to rebuild, run: [StringComparer] | fime -MemberType Property | % Name | sort -Unique | join-string -sep ",`n" -SingleQuote
            'InvariantCulture', 'InvariantCultureIgnoreCase', 'CurrentCulture', 'CurrentCultureIgnoreCase', 'Ordinal', 'OrdinalIgnoreCase', 'All'
        )]
        # [StringComparer]
        [string[]]
        $StringComparerKind = 'CurrentCultureIgnoreCase', #// [StringComparer]::CurrentCultureIgnoreCase ),

        [switch]$All,

        # return comparer instead
        [switch]$PassThru
    )
    <#
    See more:
        $query = [StringComparer]|Fime -MemberType Property | % Name
        $names = $query -as [System.StringComparison[]]

        ( [StringComparer] | Fime -MemberType Property | % Name ) -as
            [System.StringComparison[]]

    [System.StringComparison] | fime | ft -AutoSize

        ReflectedType: System.StringComparison

        Name                       MemberType Definition
        ----                       ---------- ----------
        value__                    Field      public int value__;
        CurrentCulture             Field      public const StringComparison CurrentCulture = 0;
        CurrentCultureIgnoreCase   Field      public const StringComparison CurrentCultureIgnoreCase = 1;
        InvariantCulture           Field      public const StringComparison InvariantCulture = 2;
        InvariantCultureIgnoreCase Field      public const StringComparison InvariantCultureIgnoreCase = 3;
        Ordinal                    Field      public const StringComparison Ordinal = 4;
        OrdinalIgnoreCase          Field      public const StringComparison OrdinalIgnoreCase = 5;

    [Stringcomparer]|fime | ft -AutoSize

        ReflectedType: System.StringComparer

        Name                            MemberType Definition
        ----                            ---------- ----------
        FromComparison                  Method     public static StringComparer FromComparison(StringComparison comparisonType);
        Create                          Method     public static StringComparer Create(CultureInfo culture, bool ignoreCase);
        Create                          Method     public static StringComparer Create(CultureInfo culture, CompareOptions options);
        IsWellKnownOrdinalComparer      Method     public static bool IsWellKnownOrdinalComparer(IEqualityComparer<string> comparer, out bool ignoreCase);
        IsWellKnownCultureAwareComparer Method     public static bool IsWellKnownCultureAwareComparer(IEqualityComparer<string> comparer, out CompareInfo compareIn
        Compare                         Method     public int Compare(object x, object y);
        Equals                          Method     public bool Equals(object x, object y);
        GetHashCode                     Method     public int GetHashCode(object obj);
        Compare                         Method     public abstract int Compare(string x, string y);
        Equals                          Method     public abstract bool Equals(string x, string y);
        GetHashCode                     Method     public abstract int GetHashCode(string obj);
        InvariantCulture                Property   public static StringComparer InvariantCulture { get; }
        InvariantCultureIgnoreCase      Property   public static StringComparer InvariantCultureIgnoreCase { get; }
        CurrentCulture                  Property   public static StringComparer CurrentCulture { get; }
        CurrentCultureIgnoreCase        Property   public static StringComparer CurrentCultureIgnoreCase { get; }
        Ordinal                         Property   public static StringComparer Ordinal { get; }
        OrdinalIgnoreCase               Property   public static StringComparer OrdinalIgnoreCase { get; }
    #>

    [string[]]$allNames =
        [StringComparer] | fime -MemberType Property | % Name

    if($All -or $StringComparerKind -eq 'All') {
        $StringComparerKind = $allNames
    }

    foreach($curCompareKind in $StringComparerKind) {

        $comparer = [StringComparer]::FromComparison( $curCompareKind )
        if(-not $Comparer) {
            'Error creating [StringComparer]::FromComparison( "{0}" )' -f @( $StringComparerKind ?? '' )
            | Write-error
            continue
        }
        if($PassThru) {
            $comparer
            continue
        }
        $result = $comparer.Compare( $LeftInput, $RightInput )
        $info = $meta = [ordered]@{
            PSTypeName  = '{0}.Result' -f $MyInvocation.MyCommand.Name
            CompareName = $curCompareKind
            CompareFunc = $comparer
            Left        = $LeftInput
            Right       = $RightInput
            Result      = $result
        }
        [pscustomobject]$meta
    }
}

