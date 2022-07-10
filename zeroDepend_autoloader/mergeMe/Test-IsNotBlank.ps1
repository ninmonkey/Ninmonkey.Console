#Requires -Version 7

if ( $experimentToExport ) {
    $experimentToExport.function += @(
        'Test-IsNotBlank'
    )
    $experimentToExport.alias += @(
        'Assert-IsNotBlank' # currently one function
    )
}

function Test-IsNotBlank {
    <#
    .synopsis
        asserts, todo: Maybe throw ann error too?
    .description
        Returns true if [string] is "truthy"

        Assert-IsNotBlank is an alias to always use -AlwaysThrow
    .link
        Where-IsNotBlank
    .link
        [string]::IsNullOrWhiteSpace
    .link
        Ninmonkey.Console\Test-IsNotBlank
    .link
        Ninmonkey.Console\Where-IsNotBlank
    # .link
    #     Dev.Nin\Assert-IsNotBlank
    .outputs
        boolean
    #>
    [Alias('
        !Blank',
        'text->IsNotBlank',
        'Assert-IsNotBlank'
        # 'Validation🕵.IsNotBlank',
    )]
    [outputtype([bool])]
    [cmdletbinding()]
    param(
        # Input text line[s]
        [AllowEmptyString()]
        [AllowNull()]
        [AllowEmptyCollection()]
        [Parameter(
            Mandatory, Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [string[]]$InputText,

        # false values should always throw ?
        [switch]$AlwaysThrow
    )
    process {
        # not worth a helper function to test which smart alias was used
        if ($PSCmdlet.MyInvocation.InvocationName -eq 'Assert-IsNotBlank') {
            $AlwaysThrow = $true
        }

        [bool]$IsBlank = [string]::IsNullOrWhiteSpace( $InputText )

        if ($AlwaysThrow -and $IsBlank) {
            Write-Error -ea stop -Message 'Value was blank' -TargetObject $InputText
            return $false
        }
        ! $IsBlank
        return
    }
}


if (! $experimentToExport) {
    # ...
}
