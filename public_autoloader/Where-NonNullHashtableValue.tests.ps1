BeforeAll {
    function Where-NonNullHashtableValue {
        <#
        .synopsis
            Remove null  Key->Value pairs, or by selected properties

        .description
            If non-mandatory parameters have $null values, errors can be thrown.
            # don't pass null valued optional args to invocation
        .notes
            maybe separate logic, of test without filtering

        #>        
        [ Alias('?NotNull')]
        [cmdletbinding(DefaultParameterSetName = 'AllKeys', PositionalBinding = $false)]
        param(
            # A list of keys to check
            [Parameter(
                Mandatory, Position = 0,
                ParameterSetName = 'SelectedKeys'
            )]
            [string[]]$KeyName            
        )
        
        process {
            $KeyName | Join-String -sep ', ' -op 'Keys to test: ' write-debug
            # if filters are enabled, only keep ones listed

            $selectedKeys = $writecolorSplat.keys.clone() | Where-Object {
                Write-Debug "Evaluate: Keep key?: '$Key'"
                if ($PSCmdlet.ParameterSetName -eq 'AllKeys') {
                    Write-Debug 'AllKeys: Always $true'
                    $true ; return
                }
                Write-Debug 'Filter Mode: Selected Keys Names only'
                $isValid = $KeyName -contains $_ 
                Write-Debug "'$_' Isvalid? $isValid"

                $isValid; return                 
            }
            $selectedKeys | Join-String -sep ', ' -op 'Selected Keys to test: ' | Write-Debug

            return 
            
            
            $writecolorSplat.Keys.clone() | ForEach-Object {
                $Key = $_

                if ($PSCmdlet.ParameterSetName -eq 'SelectedKeys' ) {
                    if ($KeyName -notcontains $Key) {
                        Write-Debug "Filtering: Keeping Key: '$Key'"
                        return 
                    }
                    Write-Debug "Filtering: Keeping Key: '$Key'"
                }
                
                if (! $writecolorSplat.ContainsKey($Key)) {
                    Write-Debug "Key is not in hashtable: '$Key'"
                    return
                }
                $Value = $writecolorSplat[ $Key ]
                # or maybe explicit key names : 'ForegroundColor', 'BackgroundColor'
                if ($Null -eq $value  ) {                
                    Write-Debug "Key '$Key' exists, and Value == `$null, removing."
                    $writecolorSplat.Remove( $Key )   
                    return             
                }
                Write-Debug 'Kept key: '
            }
        }   
    }
}    

Describe 'Where-NonNullHashtableValue' {
    BeforeAll {
        $DebugPreference = 'Continue'
        $Sample = @{
            AllGood     = @{ 'a' = 2 ; 'foo' = 'fds' }
            Basic       = @{ 'a' = 2 ; 'e' = $null }
            NestedEmpty = @{ 'a' = 2 ; 'emptyList' = @() }
        }
        $Expected = @{
            AllGood     = $Sample.AllGood
            Basic       = @{ 'a' = 2 }
            NestedEmpty = $Sample.NestedEmpty
        }
        $DebugPreference = 'SilentlyContinue'
    }
    It 'true' { 
        $true | Should -Be $true
    }
    It 'AllGoodValues' {
        $Sample.AllGood | Where-NonNullHashtableValue | Should -Be $Expected.AllGood
        # $Sample | Where-NonNullHashtableValue | Should -Be $Expected.AllGood
    }
}