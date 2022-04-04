using namespace System.Collections.Generic
#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Find-UnderlineMember'


    )
    $publicToExport.alias += @(
        # '__'  # 'Find-UnderlineMember
        '_'  # 'Find-UnderlineMember
        'Dunder'  # 'Find-UnderlineMember
        'Inspect->FindUnderline' # 'Find-UnderlineMember
        # 'Under'  # 'Find-UnderlineMember

        # '_' # 'Find-UnderlineMember
        # 'Find-UnderMember' # 'Find-UnderlineMember
        # 'Under' # 'Find-UnderlineMember
    )
}


function Find-UnderlineMember {
    <#
    .synopsis
        find '__' under/dunderline names, otherwise use get-variable
    .description
       This is for cases where you had to use

        PS> $Excecutation
    .notes
        future:
            - Parameter <condition> that works how Sort-Object's -Property param works
                for custom counting conditions?
    .example
        🐒> ls . | Count # how many matches?

        🐒> Inspect-FindUnderline -Scope local, global | Measure-ObjectCount
            7
        🐒> _ -scope local, global | len

        🐒> Inspect-FindUnderline -Scope global | Measure-ObjectCount
            6



    .example
        🐒> ls . | Count # how many files?
        4

        🐒> ClassExplorer\Find-Type *xml* | len

            # prints
            235
    .outputs
          [int]
    .link
        Dev.Nin\Where-IsNotBlank
    .link
        Ninmonkey.Console\Measure-ObjectCount

    #>

    [alias(
        'Find->UnderlineMember',
        '_',
        'Dunder'
        # 'Inspect->FindUnderline',
        # 'Under',
    )]
    [CmdletBinding()]
    param(
        #Input from the pipeline
        [Parameter(ValueFromPipeline)]
        [object[]]$InputObject,

        # Scope (when searching for variables)
        [Parameter(ValueFromPipeline)]
        [ArgumentCompletions('local', 'script', 'global', '0', '1', '2', '3')]
        [object[]]$Scope = 'local',

        # do not count 'Blank' values
        # [Alias('IgnoreNull')]
        # [Parameter()][switch]$IgnoreBlank
        [Parameter()]
        [Hashtable]$Options = @{}


    )
    begin {
        $Config = @{
            'IncludePSBase'           = $true
            'Search_Regular'          = $True
            'Search_PSBase'           = $True
            'Search_PSObjectProperty' = $True
            # 'IgnorePatterns' = @( # variable names to ignore
            'IgnoreList'              = @( # variable names to ignore
                # '____snap',
                # '__dupCounter',
                # '__nancy',
                # '__ninConfig',
                # '__warn',
                # '_OLD_VIRTUAL_PATH'
            )

        }
        $Config = Join-Hashtable $Config $Options
        $Config | format-dict | Out-String | Write-Debug

        $objectList = [List[object]]::new()
    }
    process {
        if ($null -eq $InputObject) {
            return
        }
        $objectList.AddRange( $InputObject )

    }
    end {
        if ($ObjectList.count -le 0) {
            $Scope | ForEach-Object {
                $curScope = $_
                Get-Variable '_*' -Scope $curScope
            }
            'search vars' | Write-Warning
            return

        }
        'search object' | Write-Warning
        $ObjectList | ForEach-Object {
            $target = $_

            $underPropNames = @(
                if ($Config['Search_PSBase']) {

                    $target.psbase | Get-Member -Name '_*' -Force
                    $target.psbase | Get-Member -Name '_*' -Static
                }
                if ($Config['Search_Regular']) {

                    $target | Get-Member -Name '_*' -Force
                    $target | Get-Member -Name '_*' -Static
                }
                if ($Config['Search_PSObjectProperty']) {
                    $target.psobject.Properties.name -match '^_.*'
                }
            ) | ForEach-Object Name | Sort-Object -Unique
            | Where-Object {
                $_ -notin $Config.IgnoreList
            }
        }
    }
}
