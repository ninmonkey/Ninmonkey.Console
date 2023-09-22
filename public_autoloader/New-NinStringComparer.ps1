
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
        $StringComparerKind = @(
            [StringComparer]::CurrentCultureIgnoreCase ),

        [switch]$All,

        # return comparer instead
        [switch]$PassThru
    )
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

