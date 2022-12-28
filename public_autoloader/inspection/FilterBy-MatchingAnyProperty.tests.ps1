BeforeAll {
    Import-Module Ninmonkey.console -Force *>$Null
}

Describe 'FilterBy-MatchesAnyProperty' -pending -Because 'Look up verbs to simplify this mess' {
    Context 'hardCoded cases' {
        BeforeAll {
            $Obj = @{}
            $Obj.Bob = [pscustomobject]@{
                Name        = 'Bob'
                Species     = 'Human'
                Description = 'Human'
            }
            $Obj.George = [pscustomobject]@{
                Name        = 'Curious George'
                Species     = 'Monkey'
                Description = 'Sort-of-Human'
            }
            $Obj.Jen = [pscustomobject]@{
                Name        = 'Jen'
                Species     = 'Human'
                Description = 'Human'
            }
            $Obj.Ant = [pscustomobject]@{
                Name        = 'Jane'
                Species     = 'Formicidae'
                Description = 'https://en.wikipedia.org/wiki/Ant'
            }
            $Obj.Bee = [pscustomobject]@{
                Name        = 'Beyoncé'
                Species     = 'Bee'
                Description = 'https://en.wikipedia.org/wiki/Bee'
            }

            $SampleGroup = @{
                First      = @(
                    $Obj.Bob
                    $Obj.Jen
                    $Obj.George
                )
                Second     = @(
                    $Obj.Bob
                    $Obj.Jen
                    $Obj.George
                    $Obj.Ant
                    $Obj.Bee
                )
                Everything = @(
                    $Obj.Values
                    # as distinct
                    | Sort-Object -Prop { $_.Name, $_.Species, $_.Description } -Unique -Stable
                )
            }
        }
        Describe 'As a Bool' -pending -Because 'cat attack mid writing, so stuff is weird.' {
            It 'Returns [bool]' {
                Get-Date
                | ?AnyPropMatch -Name 'name' -Regex '.*' -TestAsBool
                | Should -BeOfType 'bool'
            }
            It 'RequireBetterVerbage for testing' {
                #

                $SampleGroup.Second
                | Ninmonkey.Console\FilterBy-MatchesAnyProperty -PropertyNames Name -Regex 'jen|beyon' -TestAsBool | Should -BeOfType 'bool'

                # $ExpectExact =
                # $SampleGroup.Second
                # | Ninmonkey.Console\FilterBy-MatchesAnyProperty -PropertyNames Name -Regex 'jen|beyon' -TestAsBool
                # | Should -BeExactly $ExpectExact
            }
            It 'a case?' {

                $SampleGroup.Second
                | Where-Object {
                    $_ | Ninmonkey.Console\FilterBy-MatchesAnyProperty -PropertyNames Name -Regex 'jen|beyon' -TestAsBool }
            }
            It 'ex 2' {
                $result = (
                    $SampleGroup.Second
                    | Ninmonkey.Console\FilterBy-MatchesAnyProperty -PropertyNames Name -Regex 'jen|beyon'
                )
                $result.count | Should -BeOfType ''
                .Count | Should -Be 2 -Because 'manual test case'
            }
        }

        Describe 'As a ?filter' {
            It 'Base case' {
                $SampleGroup.First.Count | Should -BeExactly 3 -Because 'manual test case'

                (
                    $SampleGroup.Second
                    | Ninmonkey.Console\FilterBy-MatchesAnyProperty -PropertyNames Name -Regex 'jen|beyon'
                ).Count | Should -Be 2 -Because 'manual test case'

            }
            <#
            $SampleGroup.Everything
            | ?{ $_.species -match 'human' -or $_.description -match 'human' }
        #>
            It 'Matches "Human"' {
                $query = @{
                    human = $SampleGroup.First | Where-Object { $_.Species -eq 'human' }
                }

                $query.human.count | Should -BeExactly 2 -Because 'manual test case'

            }
        }
    }
}