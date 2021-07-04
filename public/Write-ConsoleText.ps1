function Write-ConsoleText {
    # [Alias('Text', 'Write-Color')] # maybe: Write-Text ?
    <#
    .synopsis
        Writes a colored, ANSI escaped string.
    .description
        Optionally padding as with newlines
        Base function used by other commands like Write-ConsoleHeader, Write-ConsoleLabel
    .example

        # Pansies Sep is an object
        $sep = new-text -fg 'orange' '--'
        New-Text ('a'..'z') -sep $sep | % tostring
    .notes
    #>
    [cmdletbinding(
        # DefaultParameterSetName =
        PositionalBinding = $false
    )]
    [Alias('Write-Text')]
    param(
        # String to write
        # New-Text supports [object].
        # Should I allow that here?
        [Alias('Text')]
        [Parameter(Mandatory, Position = 0)]
        # [string]$Text, # Object text?
        [object]$Object, # Object text?

        # New-Text supports [object]$Separator.
        # Should I allow that here?
        [Parameter()]
        [object]$Separator, # Object text?

        # Foregorund Color as text/hex/rgb (Anything supported by "PoshCode.Pansies.RgbColor"
        [Parameter(Mandatory, Position = 1)]
        [alias('Fg')]
        [PoshCode.Pansies.RgbColor]$ForegroundColor,

        # Background Color as text/hex/rgb (Anything supported by "PoshCode.Pansies.RgbColor"
        [Parameter()]
        [alias('Bg')]
        [PoshCode.Pansies.RgbColor]$BackgroundColor,

        # number of blank lines before Label
        [Parameter()]
        [Alias('Before')]
        [uint]$LinesBefore = 0,

        # number of blank lines after Label
        [Parameter()]
        [Alias('After')]
        [uint]$LinesAfter = 0

        # # how deep, h1 to h6
        # [Parameter()]
        # [uint]$Depth = 1
    )

    begin {}
    Process {
        $Prefix = "`n" * $LinesBefore
        $Suffix = "`n" * $LinesAfter

        $Text_splat = $pscmdlet.MyInvocation.BoundParameters

        # New-Text supports [object].
        # Should I allow that here?
        $Text_splat.remove( 'Object' )
        $Obj = $prefix, $Object, $Suffix -join ''
        $Text_splat.add( 'Object', $Obj )

        $Text_splat.Remove('LinesBefore')
        $Text_splat.Remove('LinesAfter')



        # 'TextSplat = {0}' -f $Text_splat
        # "textSplat = $([pscustomobject]$Text_splat)"
        # "textSplat = $([pscustomobject]$Text_splat)"
        $Text_splat | Format-Table | Out-String -Width 999 | Write-Debug
        New-Text @Text_splat
    }
    end {}

}
