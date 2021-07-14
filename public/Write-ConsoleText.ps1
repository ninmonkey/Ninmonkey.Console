function Write-ConsoleText {
    <#
    .synopsis
        Writes a colored, ANSI escaped string.
    .description
        Optionally padding as with newlines
        Base function used by other commands like Write-ConsoleHeader, Write-ConsoleLabel

        The verb 'write' may not be right, but I wanted to avoid a direct collision
            with Pansies\Text and Pansies\New-Text
    .example
        Write-Text 'hi' -ForegroundColor green
    .example

        # Pansies Sep is an object
        $sep = new-text -fg 'orange' '--'
        New-Text ('a'..'z') -sep $sep | % tostring
    .notes
    #>
    # [Alias('Text', 'Write-Color')] # maybe: Write-Text ?
    [Alias('Write-Text')]
    [cmdletbinding(
        # DefaultParameterSetName =
        PositionalBinding = $false
    )]
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
        [uint]$LinesAfter = 0,

        # Force coercion to string immediately
        [Alias('Force')]
        [Parameter()][switch]$AsString

        # # how deep, h1 to h6
        # [Parameter()]
        # [uint]$Depth = 1
    )

    begin {}
    Process {
        $Prefix = "`n" * $LinesBefore
        $Suffix = "`n" * $LinesAfter

        # might use smart aliases here
        $Text_splat = $pscmdlet.MyInvocation.BoundParameters

        # Looks akward. I was planning for dynamic aliases
        [void]$Text_splat.remove( 'Object' )
        $Obj = $prefix, $Object, $Suffix -join ''
        [void]$Text_splat.add( 'Object', $Obj )
        [void]$Text_splat.Remove('LinesBefore')
        [void]$Text_splat.Remove('LinesAfter')

        $Text_splat | Format-Table | Out-String -Width 999 | Write-Debug
        $textObj = New-Text @Text_splat

        if ($AsString) {
            $textObj.ToString()
            return
        }
        $textObj
    }
    end {}

}
