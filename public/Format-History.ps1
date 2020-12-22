function Format-History {
    <#
    .synopsis
        Pretty print history using syntax highlighting
    .description
        filters out duplicate commands
    .notes
        - [ ] better  methods for piping text to native app multiple times?
        Parameterset was used to test improving performance
        bottleneck is whether 'pygmentize' is called once per command, or once per entire call
    .example
        PS> Format-History
        PS> Format-History -Count 3
        PS> Get-History -Count 3 | Format-History

        PS> Get-History | ? CommandLine  -match '^format'

        PS> Get-History | ? CommandLine -match '\$' | Format-History
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

        # Regex to filter $_.CommandLine
        # [Parameter(Position = 0)]
        # [string]$Pattern,

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

        $Template = @{
            SingleCommand = @'
# Id: {0,2} >>
{1}
'@
        }

        $Config | Format-HashTable -Title 'Config' | Write-Debug
        # "`n`n"
    }

    Process {
        $splat_JoinString_Commandline = @{
            # OutputPrefix = "`n`n`n`n`n`n"
            # Separator = "`n`n"
            # Separator = @("`n", (hr)) -join ''
            Separator = @("`n", (hr 2)) -join ''
            # Separator = '-' * 10
            # Property  = 'CommandLine'
            Property  = {
                $Template.SingleCommand -f @(
                    $_.Id
                    # 1($_.Id | Label '' -sep '')
                    # (Label 'Id' $_.Id)
                    $_.CommandLine
                )
            }


        }
        switch ($PSCmdlet.ParameterSetName) {
            'FromPipe' {
                $InputObject
                | Join-String @splat_JoinString_Commandline
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
    end {
        if ($PSCmdlet.ParameterSetName -eq 'fromPipe') {
            Write-Warning 'fromPipe: need to refactor for performance, pass entire block to pygmentize'
        }
    }
}


# # 30 + 4
# # 'a'..'z' | Join-String -sep ', '

# # H1 'manual'
# # Format-History | Select-Object -Last 3 | Format-History

# # H1 'implicit'
# # hr 2
# if ($false) {

#     Format-History -Count 3
#     H1 'next'
#     Get-History -Count 3 | Format-History

#     # Get-History -Count 3 | Format-History
#     Get-History -Count 40
#     | Format-History #-Pattern 'sfdfffd'
# }