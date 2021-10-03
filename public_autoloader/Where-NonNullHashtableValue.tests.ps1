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
            - is it performant enough? does it pass a reference?

        #>
        [ Alias('?NotNull')]
        [cmdletbinding(PositionalBinding = $false)]
        param(
            # hashtable to evaluate.
            [Alias('HashTable')]
            [ValidateNotNull()]
            [parameter(Mandatory, ValueFromPipeline)]
            [hashtable]$InputObject,



            # A list of keys to check
            # simplified param sets by making it optional
            [Alias('Keys')]
            [Parameter(
                Position = 0
                # ParameterSetName = 'SelectedKeys'
            )]
            [string[]]$KeyName
        )

        process {
            $writecolorSplat = $InputObject
            [bool]$IsUsingAllKeys = $KeyName.count -gt 0
            "Using all keys? $UsingAllKeys" | Write-Debug
            $KeyName | Join-String -sep ', ' -op 'Keys to test: ' | Write-Debug
            # if filters are enabled, only keep ones listed

            $selectedKeys = $writecolorSplat.keys.clone() | Where-Object {
                Write-Debug "Evaluate: Keep key?: '$Key'"
                if ($IsUsingAllKeys) {
                    Write-Debug '$IsUsingAllKeys: Always $true'
                    $true ; return
                }
                Write-Debug 'Filter Mode: Selected Keys Names only'
                $isValid = $KeyName -contains $_
                Write-Debug "'$_' Isvalid? '$isValid'"

                $isValid; return
            }
            $selectedKeys | Join-String -sep ', ' -op 'Selected Keys to test: ' | Write-Debug

            $selectedKeys | ForEach-Object {
                $Key = $_
                Write-Debug "Evaluate: Is Key: '$Key' `$null ?"
                if (! $writecolorSplat.ContainsKey($Key)) {
                    Write-Debug "Key is not in hashtable: '$Key'"
                    return
                }
                $Value = $writecolorSplat[ $Key ]
                # or maybe explicit key names : 'ForegroundColor', 'BackgroundColor'
                Write-Debug 'Evaluate: Is Value $Null?'
                if ($Null -eq $value  ) {
                    Write-Debug "Key '$Key' exists, and Value == `$null, removing."
                    $writecolorSplat.Remove( $Key )
                    return
                }
                Write-Debug "Kept key: '$Key'"
            }

            $writecolorSplat

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
            AllGood     = @{ 'Something' = 2 ; 'foo' = 'fds' }
            BasicNull   = @{ 'Something' = 2 ; 'EmptyReference' = $null }
            NestedEmpty = @{ 'Something' = 2 ; 'emptyList' = @() }
        }
        $Expected = @{
            AllGood     = $Sample.AllGood
            BasicNull   = @{ 'Something' = 2 }
            NestedEmpty = $Sample.NestedEmpty
        }
        $DebugPreference = 'SilentlyContinue'
    }
    It 'AllGoodValues' {
        $Sample.AllGood | Where-NonNullHashtableValue -Debug | Should -Be $Expected.AllGood
        # $Sample | Where-NonNullHashtableValue | Should -Be $Expected.AllGood
    }
    Describe 'Explicit Included Keys' {
        BeforeAll {
            $true | Should -Be $false -Because 'NYI'
            $Sample.Explicit_BasicNull = @{ 'Something' = 2 ; 'EmptyReference' = $null; 'EmptyString' = '' }
            # $Expected.Explicit_BasicNull   = @{ 'Something' = 2 ; 'EmptyString' = '' }
            $OriginalHash = @{ 'Something1' = 1; 'NulLValue' = $Null ; 'EmptyString' = '' ; 'EmptyList' = @() }
            'try1:
                - no keys, shouldl auto remove just null
                - with -Key "NullValue"
                - with key including null value
                - make sure empty, ie: non-null empty don''t trigger
            '
            $SampleCase = @(
                @{
                }
            )
            # $OriginalHash = @{ 'Something1' = 1; 'NulLValue' = $Null ; 'EmptyString' = '' ; 'EmptyList' = @() }
        }
        It 'Keep Basic $Null Value' {
            $true | Should -Be $false -Because 'NYI'
            $Sample.AllGood | Where-NonNullHashtableValue -Debug -Key 'Something'
            | Should -Be $Expected.AllGood
            # $Sample | Where-NonNullHashtableValue | Should -Be $Expected.AllGood
        }
    }
    It 'Single $Null Value' {
        # $true | Should -Be $false -Because 'NYI'
        $Sample.BasicNull | Where-NonNullHashtableValue -Debug | Should -Be $Expected.BasicNull
        # $Sample | Where-NonNullHashtableValue | Should -Be $Expected.AllGood
    }
}