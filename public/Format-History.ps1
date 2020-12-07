function Format-History {
    <#
    .synopsis
        Pretty print history using syntax highlighting
    .description
        filters out duplicate commands
    .notes
        Parameterset was used to test improving performance
        bottleneck is whether 'pygmentize' is called once per command, or once per entire call
    .example
        PS> Format-History
        PS> Get-History -count 50 | ? CommandLine -match '\$' | Format-History
    #>
    [CmdletBinding(DefaultParameterSetName = 'FromNone')]
    param(
        # simple output
        # [Parameter()][switch]$Basic,

        # Disable ANSI color output
        [Parameter()][switch]$NoColor,

        # -Count for Get-History
        [Parameter()]
        [int32]$Count = 20,

        # Input history from pipeline
        # [Parameter(ParameterSetName='fromPipe', Mandatory, Position=0, ValueFromPipeline)]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'FromPipe')]
        $InputObject
    )

    # Get-History | Where-Object CommandLine -Match 'lastCmd' | ForEach-Object CommandLine | pygmentize.exe -l ps1
    begin {
        $Config = @{
            # InsertNewlineOnPipe       = $true
            # invoke pygment on every single result (slower than a batch)
            # SyntaxHighlightIndividual = $false
            # Basic                     = $Basic
            ParameterSetName = $PSCmdlet.ParameterSetName
        }

        $Config | Format-HashTable -Title 'Config' | Write-Debug
    }

    Process {
        $splat_JoinString_Commandline = @{
            Separator = "`n`n"
            Property  = 'CommandLine'
        }
        switch ($PSCmdlet.ParameterSetName) {
            'FromPipe' {
                $InputObject | Join-String @splat_JoinString_Commandline
                | pygmentize.exe -l ps1
                continue
            }
            'FromNone' {
                Get-History -Count $Count
                | Join-String @splat_JoinString_Commandline
                | pygmentize.exe -l ps1
                continue
            }
            default { throw "UnhandledParmeterSetName: $($PSCmdlet.ParameterSetName)" }
        }
    }
}
