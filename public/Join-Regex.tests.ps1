#requires -modules @{ModuleName='Pester';ModuleVersion='5.0.0'}
$SCRIPT:__PesterFunctionName = $myinvocation.MyCommand.Name.split('.')[0]

BeforeAll {
    Import-Module Ninmonkey.Console -Force
    # . $(Get-ChildItem -Path $PSScriptRoot/.. -Recurse -Filter "Join-Regex.ps1")
    # $Mocks = Resolve-Path "$PSScriptRoot/Mocks"
    # $ErrorActionPreference = 'break'
    $ErrorActionPreference = 'stop'

}

Describe 'Join-Regex' -Tag {
    It 'Runs without error' {
        # . Join-Regex
        Join-Regex -Regex 'a', 'b'
    }
    It 'No Params Should Error' {
        { Join-Regex } | Should -Throw -Because 'No inputs mean no regex'
    }
    Describe 'Only Literals' {
        It 'Returns "<expected>" - "<Regex>"' -ForEach @(
            @{
                Text = 'a', 'b' ; Expected = '((a)|(b))'
            }
            @{
                Text     = $env:USERPROFILE
                Expected = '((' + [regex]::Escape($env:USERPROFILE) + '))'
                # currently a single element returns: ((C:\\Users\\cppmo_000))
            }
        ) {
            Join-Regex -Text $Text | Should -Be $Expected
        }
    }
    Describe 'Only Regex' {
        It 'Returns "<expected>" - "<Regex>"' -ForEach @(
            @{
                Regex    = '[a-z]+', '\d{3}'
                Expected = '(([a-z]+)|(\d{3}))'
            }
            @{
                Regex    = $env:USERPROFILE
                # '((C:\Users\cppmo_000))'
                Expected = '((' + $env:USERPROFILE + '))'
                # currently a single element returns: ((C:\\Users\\cppmo_000))
            }
        ) {
            Join-Regex -Regex $Regex | Should -Be $Expected
        }
    }
    Describe 'Both Regex and Literals Regex' {
        It 'Returns "<expected>" from ⇒ "<Regex>" and "<Text>"' -ForEach @(
            @{
                Text     = 'a', 'b'
                Regex    = '[a-z]+'
                Expected = '((a)|(b))|(([a-z]+))'
            }
            @{
                Text     = $env:USERPROFILE
                Regex    = '[a-z]+'
                Expected = '((' + [regex]::Escape($env:USERPROFILE) + '))' + '|(([a-z]+))'

            }
        ) {
            Join-Regex -Text $Text -Regex $Regex | Should -Be $Expected
        }
    }
}
