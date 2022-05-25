BeforeAll {
    Import-Module Ninmonkey.Console -DisableNameChecking -Force *>$Null
    # note: requires first-pass
}

Describe 'Inspect Enumerable' {
    BeforeAll {

        $manyEnv = Get-ChildItem env:
        $manyColor = Get-ChildItem env:

        $envItem = Get-Item env:\
        $colorItem = Get-Item Fg:\red
        Get-Item Env:\TEMP | InspectEnumerable
    }
    Context 'missing get-enumerator' {
        <#
        [System.Collections.DictionaryEntry] does not contain
     | a method named 'GetEnumerator'
     #>
        It 'DictionaryEntry-does not have method' -Skip {
            # not sure if I need to collect, then test? or just require param as array?
            { $manyColor | InspectEnumerable } | Should -Not -Throw
        }
    }



    It 'remaining' -Pending {
        Set-ItResult -Pending 'quick wip'
        return

        $params = (Get-Command Get-Culture).Parameters
        InspectEnumerable $params #| Format-List
        Hr
        Get-Item env: | InspectEnumerable | Format-List


        H1 '1'
        $manyEnv = Get-ChildItem env:
        H1 '2'
        $manyColor = Get-ChildItem env:
        H1 '3'

        $envItem = Get-Item env:\
        H1 '4'
        $colorItem = Get-Item Fg:\red
        Get-Item Env:\TEMP | InspectEnumerable
        H1 '5'

    }



}
