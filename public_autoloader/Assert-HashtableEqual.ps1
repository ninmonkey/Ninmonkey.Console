using namespace System.Management.Automation
$script:publicToExport.function += @(
    'Assert-HashtableEqual'
)
# $script:publicToExport.alias += @()


function Assert-HashtableEqual {
    <#
        .synopsis
            Do two hashtables have the same number of keys, and the same names?
        .description
            This does not test values other than type compatability

            see also:
                Assert\Assert-All
                Assert\Assert-Contain
        .notes
            future:
                - [ ] extract function to not require lib
                - [ ] case-sensitive comparison
                - [ ] whether values are the same datattype
        #>
    [OutputType([bool])]
    [CmdletBinding()]
    param(
        # Left side
        [Alias('Hash1')]
        [parameter(Mandatory, Position = 0)]
        [hashtable]$InputHash,

        # Right Side
        [Alias('Hash2')]
        [parameter(Mandatory, Position = 1)]
        [hashtable]$OtherHash

        # Force Case Sensitivity
        # [Switch]$CaseSensitive
    )
    end {
        $hash1 = [HashSet[string]]::new(
            [string[]]($InputHash.Keys),
            [System.StringComparer]::OrdinalIgnoreCase
        )
        $hash2 = [HashSet[string]]::new(
            [string[]]($OtherHash.Keys),
            [System.StringComparer]::OrdinalIgnoreCase
        )
        $hash1 | Join-String -sep ', ' -op 'set1: ' | Write-Debug
        $hash2 | Join-String -sep ', ' -op 'set2: ' | Write-Debug

        $AreEqual = $hash1.SetEquals( $hash2 )
        Write-Debug "Result: $AreEqual"
        if (! $AreEqual ) {
            $false; return
            # I'm not sure if I want to throw
            #     Write-Error -ea Stop -Message 'Keys do not match' -Category InvalidData -ErrorId 'HashtableEqualKeys' -TargetObject @(
            #         $hash1
            #         $hash2
            #     )
        }


        $true ; return
    }
}