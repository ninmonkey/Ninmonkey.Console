if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'Compare-LongestSharedPrefix'
    )
    $script:publicToExport.alias += @(
        'longestSharedStr'  # 'Compare-LongestSharedPrefix'
        'str->Shared'  # 'Compare-LongestSharedPrefix'
    )
}

function Compare-LongestSharedPrefix {
    <#
    .SYNOPSIS
        currently checks max [char] lengths in common
    .NOTES
        hacky, incremental tests, no longer required / to cleanup
        future: toggle case sensitivity, and make it off by default

        future: pass thru  the metadata

        future:
            add longest shared string without requiring it to be a prefix

            while ($long.contains($short)) {
                $short++
            }

    .LINK
        https://docs.microsoft.com/en-us/dotnet/csharp/how-to/compare-strings
    .LINK
        https://docs.microsoft.com/en-us/dotnet/standard/base-types/comparing#compareordinal-method
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.string.equals?view=net-6.0#system-string-equals(system-string-system-string-system-stringcomparison)
    .LINK
        https://docs.microsoft.com/en-us/dotnet/api/system.string.compare?view=net-6.0

    #>
    [OutputType('System.String')]
    [Alias(
        'longestSharedStr',
        'str->Shared'
    )]
    [CmdletBinding()]
    param(
        [AllowNull()]
        [Parameter(Mandatory)]
        [Alias('A')]
        [string]$Text1,

        [AllowNull()]
        [Parameter(Mandatory)]
        [Alias('B')]
        [string]$Text2,

        [switch]$AsChar, ##/ = $true,
        [switch]$AsCodepoint,

        # maybe also -SmartCaseSensitive?
        [switch]$CaseSensitive,
        [switch]$PassThru
    )
    if (-not $AsChar -and -not $asCodepoint) {
        $AsChar = $True
        # write-warning 'no types to be tested'
        # return [string]::Empty
    }
    # meta info for -PassThru
    $dbg = @{
        Text1 = $Text1
        Text2 = $text2
    }
    if ($CaseSensitive) {
        throw 'to add'
    }
    # handles any nulls or empty strings
    if ($Text1.Count -eq 0 -or $Text2.Count -eq 0) {
        return [string]::Empty
    }
    if ($Text1 -eq $Text2) {
        return $Text1
    }

    $maxLen = [Math]::Min( $Text1.Length, $Text2.Length )
    $uniLen1 = $Text1.EnumerateRunes().Value.Count
    $uniLen2 = $Text2.EnumerateRunes().Value.Count
    $maxUniLen = [Math]::min( $uniLen1, $uniLen2 )
    if ($uniLen1 -lt $uniLen2) {
        $strShort = $Text1
        $strLong = $Text2
    } else {
        $strShort = $Text2
        $strLong = $Text1
    }
    if ( -not ($strLong.StartsWith($strShort))) {
        return [string]::Empty
    }

    $dbg.StrShort = $strShort
    $dbg.StrLong = $strLong
    $dbg.Text1_length = $Text1.Length
    $dbg.Text2_length = $Text2.Length
    $dbg.maxLen = $MaxLen
    $dbg.maxUniLen = $MaxUniLen

    if ($AsCodepoint) {
        throw 'NYI'
    }
    # at this point we know StartsWith is true, its just how long
    if ($AsChar) {
        $sharedLen = foreach ($subStrLength in 1..($strShort.length)) {
            $partialShort = $strShort.SubString(0, $charIndex)
            $partialLong = $strLong.subString(0, $charIndex)
            if ($partialShort -eq $partialLong) {
                if (-not $PassThru) {
                    return $partialShort
                }
                $dbg.sharedLen = $sharedLen
                $dbg.Match = $partialShort
                return [pscustomobject]$dbg

            }
        }

        if ( -not $PassThru ) {
            return $strShort.Substring(0, $sharedLen)
        }

        $dbg.sharedLen = $sharedLen
        $dbg.Match = $strShort.Substring(0, $sharedLen)
        return [pscustomobject]$dbg

    }

    # throw 'wip'
    throw 'ShouldNeverReachException:'
}
