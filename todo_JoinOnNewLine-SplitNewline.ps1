'situation where you force split on nefwline, or join on, to always ensure code will run '
if ($false) {

    Get-Command -Module ClassExplorer #| Join-String -sep "`n"
    | Join-String { $_.Source, $_.Name -join '\' } -Separator "`n"
    | Sort-Object
    | ForEach-Object { $_ -split '\n' }  # here
    | Join-String -Sep ', '


    function JoinOnNewline {
        $_ -join "`n" # ex1
        # any advantage to this?
        $_ | Join-String -sep  "`n" #ex2
        # maybe ex2 doesn't have to finish processing, plus load entire list into memory
        # vs ex2 which may (depending down the line) process as chunks in a stream
    }
    function SplitOnNewline {
        $_ -split '\r?\n'
    }

    function PipelineSplitString {
        <#

        #>
    }
    function PipelineRegexSplit {
        <#

        #>
    }


    'nonsense example case
        just sugar
    '
    $inputSample = 0..30
    $inputSample -join ', ' | ForEach-Object { $_ -split ', ' } -join ':'

    $Input2 = Get-ChildItem 'C:\Windows\'



    h1 'ex:'
    $inputSample -join ', ' -replace ', ', ':'

    h1 'ex:'
    $Input2 | Get-Random -Count 5 | Join-String -sep ', ' Name




    0..30 -join ', ' -split ', ' -join "`n"
}