<#
created:
    Jake
    2021-05-11
refs:
    - https://github.com/PowerShell/PSScriptAnalyzer#suppressing-rules

examples:
    - https://github.com/indented-automation/Indented.ScriptAnalyzerRules

#>

@{
    Severity = @(
        'Error'
        'Warning'
    )
    # ExcludeRules = @(
    #     'PSDSC*'
    #     'PSUseDeclaredVarsMoreThanAssignments'
    #     'PSUseShouldProcessForStateChangingFunctions'
    # )

    Rules    = @{
        # disable 'process' because tiny typo-s mutates proccess expressions by accident
        PSAvoidUsingCmdletAliases  = @{
            Enable      = $True
            'Whitelist' = @('process')
        }
        'AvoidGlobalAliases'       = @{
            Enable = $True
        }
        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }


        PSUseConsistentIndentation = @{
            # this is for WinPS, not PS pre-denting pipes
            Enable = $false
            # Kind                = 'space'
            # PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            # IndentationSize     = 4
        }

        PSUseConsistentWhitespace  = @{
            Enable                          = $true
            CheckInnerBrace                 = $true
            CheckOpenBrace                  = $true
            CheckOpenParen                  = $true
            CheckOperator                   = $false
            CheckPipe                       = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator                  = $true
            CheckParameter                  = $false
        }

        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }

        PSUseCorrectCasing         = @{
            Enable = $true
        }

        <#
        how to create a new or custom compatible list:
            <https://github.com/PowerShell/PSScriptAnalyzer/blob/master/RuleDocumentation/UseCompatibleCmdlets.md>

        #>
        # 'PSUseCompatibleCmdlets'    = @{
        #     'compatibility' = @("coreff-6.1.0-windows")
        # }
    }
}
