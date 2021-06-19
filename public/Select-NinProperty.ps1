using namespace System.Collections.Generic

function Select-NinProperty {
    <#
    .synopsis
        Takes a list of objects, distinct sorted values are piped to Fzf for selection
    .description
        Uncertain on aliases. the goal is to have one that defaults
        to calling Fzf, and one that does not. ( ie: default invert of -PassThru)
    .notes
        future:
            - [ ] -NoSort, -NoDistinct: params
            - [ ] -UseCache param: so additional calls don't invoke Fzf
    .example
        PS>
    #>
    [Alias('SelectProp', 'Select-Property', 'PropList')]
    [CmdletBinding(  PositionalBinding = $false)]
    param (
        # source objects
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$InputObject,

        # source objects
        [Parameter(Mandatory, Position = 0 )]
        [string]$PropertyName,

        # Returns a list directly, list, skipping Fzf
        [Parameter()][switch]$PassThru,

        # Make errors fatal. Otherwise default behavior is to return nothing
        # You may opt-in to returning the value: '[␀]' instead of nothing
        # $Config.OnError_ReturnNullString = $True
        [Parameter()][switch]$Strict
    )

    begin {
        $all_properties = [list[object]]::new()
        $Config = @{
            OnError_ReturnNullString = $false
        }
    }
    process {
        $InputObject | ForEach-Object {
            $curObj = $_
            $PropValue = $curObj.$PropertyName

            if ($Null -eq $PropValue) {
                # Test whether property exists and is set to null
                # or doesn't exist
                if ($Strict) {
                    $propExists = $PropertyName -in $curObj.psobject.properties.name
                    Write-Error "`$null value, '$PropertyName' exists?: $propExists"
                    # Is it preferable to use an error, and exit, or throw an exception?
                    # The latter would break the entire pipeline, forcing the user to use ignore?
                    # The user expects  behavior isl
                    return
                }
                else {
                    <#
                    $nullStr is more useful once multiple properties per-object are involved
                        or if you want to gaurentee an
                    #>
                    if ($Config.OnError_ReturnNullString) {
                        $PropValue = "[`u{2400}]"
                        $all_properties.Add( $PropValue  )
                    }
                    return
                }
            }

            $all_properties.Add( $PropValue  )

        }
    }
    end {
        switch ($PSCmdlet.MyInvocation.InvocationName) {
            'PropList' {
                $PassThru = $true
                break
            }
        }


        $distinct_props = $all_properties | Sort-Object -Unique
        if ($PassThru) {
            $distinct_props
            return
        }

        $num = $distinct_props.Count
        if ($num -eq 0) {
            return
        }
        elseif ($true) {

        }

        if ($distinct_props.Count -eq 1) {
            $distinct_props
            return
        }

        $distinct_props
        | Out-Fzf -PromptText "Select $PropertyName"
    }
}


if ($InteractiveTest) {
    # with Fzf
    Get-Module | Select-NinProperty -PropertyName Name
    # Without Fzf
    Get-Module | Select-NinProperty -PropertyName Name -PassThru
}
