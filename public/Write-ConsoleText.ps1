function Write-ConsoleText {
    <#
    .synopsis
        Writes a colored, ANSI escaped string.
    .description
        Optionally padding as with newlines
        Base function used by other commands like Write-ConsoleHeader, Write-ConsoleLabel

        The verb 'write' may not be right, but I wanted to avoid a direct collision
        with Pansies\Text and Pansies\New-Text
    .notes
        Wrapper/sugar for Write-Color, smart-aliases choose different defaults
    .example
        Write-Text 'hi' -ForegroundColor green
    .example

        # Pansies Sep is an object
        $sep = new-text -fg 'orange' '--'
        New-Text ('a'..'z') -sep $sep | % tostring
    #>
    # [Alias('Text', 'Write-Color')] # maybe: Write-Text ?
    [Alias('Write-Text')]
    [cmdletbinding(
        DefaultParameterSetName = 'FromParams',
        PositionalBinding = $false
    )]
    param(
        # String to write
        # New-Text supports [object].
        # Should I allow that here?
        [Alias('Text', 'Object')]
        [Parameter(
            ParameterSetName = 'FromPipeline', Mandatory, ValueFromPipeline)]
        [Parameter(
            ParameterSetName = 'FromParams', Mandatory, Position = 0)]
        # [string]$Text, # Object text?
        [object]$InputObject, # Object text?

        # New-Text supports [object]$Separator.
        # Should I allow that here?
        [Parameter()]
        [string]$Separator = '', # Object text?

        # Foregorund Color as text/hex/rgb (Anything supported by "PoshCode.Pansies.RgbColor"
        [alias('Fg')]
        [Parameter(
            ParameterSetName = 'FromPipeline', Position = 0)]
        [Parameter(
            ParameterSetName = 'FromParams', Position = 1)]
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

        # Force coercion to string immediately? That might become the default
        [Alias('Force')]
        [Parameter()][switch]$AsString

        # # how deep, h1 to h6
        # [Parameter()]
        # [uint]$Depth = 1
    )

    begin {
        if ($AsString) {
            Write-Error '-AsString:$false' -Category NotImplemented
        }
    }
    Process {

        # New-Text 'hi world' -fg green | ForEach-Object tostring
        $Prefix = "`n" * $LinesBefore
        $Suffix = "`n" * $LinesAfter

        # might use smart aliases here
        $Text_splat = $pscmdlet.MyInvocation.BoundParameters
        $smartAlias = $pscmdlet.MyInvocation.InvocationName -eq @('Pair', 'wH1', 'wHr')
        switch ($smartAlias) {
            'wH1' {
                $Fg = 'orange'
            }
            'Write-ConsoleText' {
                #
            }
            default {
                Write-Debug "Smart alias NYI: '$smartAlias'"
            }
        }
        $writecolorSplat = @{
            ForegroundColor = $ForegroundColor
            BackgroundColor = $BackgroundColor
            Text            = $InputObject -join $Separator
        }
        
        # function Where-NonNullValue {
        #     <#
        #     .synoposis 
        #     #>
        #     # don't pass null valued optional args to invocation
        #     $writecolorSplat.Keys.clone() | ForEach-Object {
        #         $Key = $_
        #         if (! $writecolorSplat.ContainsKey($Key)) {
        #             return
        #         }
        #         $Value = $writecolorSplat[ $Key ]
        #         # or maybe explicit key names : 'ForegroundColor', 'BackgroundColor'
        #         if ($Null -eq $value  ) {                
        #             $writecolorSplat.Remove( $Key )                
        #         }
        #     }
        # }


        # todo: refactor: use Where-NonNullHashtableValue

        # don't pass null valued optional args to invocation
        $writecolorSplat.Keys | Join-String -sep ', ' -SingleQuote -op 'Initial Keys: ' | Write-debug
        $writecolorSplat.Keys.clone() | ForEach-Object {
            # or maybe explicit key names : 'ForegroundColor', 'BackgroundColor
            if (! $writecolorSplat.ContainsKey($_)) { return }
            $val = $writecolorSplat[$_]
            if ($Null -eq $val ) {
                $writecolorSplat.Remove( $_ )
            }
        }
        $writecolorSplat.Keys | Join-String -sep ', ' -SingleQuote -op 'Keys Kept: ' | Write-debug

        # render
        @(
            $Prefix
            write-color @writecolorSplat
            $Suffix
        ) -join ''

        # return
        # # Looks akward. I was planning for dynamic aliases
        # [void]$Text_splat.remove( 'InputObject' )
        # $ObjectWithFixes = $prefix, $InputObject, $Suffix -join $Separator
        # [void]$Text_splat.add( 'Object', $ObjectWithFixes )
        # [void]$Text_splat.Remove('LinesBefore')
        # [void]$Text_splat.Remove('LinesAfter')
        # $AsString = ($Text_splat)?['AsString'] ?? $false
        # [void]$Text_splat.Remove('AsString')

        # $Text_splat | Format-Table | Out-String -Width 999 | Write-Debug
        # $textObj = New-Text @Text_splat

        # if ($AsString) {
        #     ($textObj)?.ToString()
        #     return
        # }
        # $textObj
    }
    end {}

}
