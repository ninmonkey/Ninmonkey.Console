#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'Format-NativeCommandArguments'
    )
    $publicToExport.alias += @(
        'nin.renderClargs' # 'Format-NativeCommandArguments'
    )
    $publicToExport.variable += @(
        # 'ninLastPath' # from: 'Ninmonkey.Console\Format-NativeCommandArguments'
    )
}

function Format-NativeCommandArguments {
    <#
    .SYNOPSIS
        render and emphasize command line args for a command
    .EXAMPLE
        $clargs = @('log', '-n', '1')
        $clargs | Format-NativeCommandArguments -CommandName 'git'
        Format-NativeCommandArguments -CommandName 'git' -Args $clargs
        # output:
             => invoke: sam log -n 1
    .EXAMPLE
        # works with positional set
        Format-NativeCommandArguments 'git' $clargs
        $clargs | Format-NativeCommandArguments 'git'
    .EXAMPLE
        Format-NativeCommandArguments 'code' '--goto', 'someFile.log:242'
    .EXAMPLE
        $clargs = @('--goto', (gi '..\README.md'))
        $clargs | Format-NativeCommandArguments 'code'
    .EXAMPLE
        get-date | sc 'temp:\now.txt'
        sleep 0.01
        get-date | sc 'temp:\now with spaces.txt'

        $vscodeDiff = @(
            '--reuse-window'
            '--diff'
            gi 'temp:\now.txt'
            gi 'temp:\now with spaces.txt'
        )

        Format-NativeCommandArguments 'code' $vscodeDiff
    .example
        Format-NativeCommandArguments -CommandName  'git' -InputArgs 'log', '-n', '1'
    #>
    [Alias('nin.renderClargs')]
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        # binary name
        [Parameter(Mandatory, Position = 0)]
        [string]$CommandName,

        # render [object[]] arguments
        [Alias('Args')]
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [object[]]$InputArgs = @()
    )
    begin {
        [Collections.Generic.List[Object]]$Items = @()
        $ColorOrange = @(
            $PSStyle.Foreground.fromRgb('#c8834b')
            $PSStyle.Background.fromRgb('#362b1f')
        ) -join ''
    }
    process {
        $items.AddRange($inputArgs)
    }
    end {
        $Items
        | Join-String -op "  => invoke: ${CommandName} " -sep ' '
        | Join-String -op $ColorOrange -os $PSStyle.Reset -sep ' '
        # $Args | Join-String -sep ' ' -op "execute => ${CommandName}: "
    }
}
