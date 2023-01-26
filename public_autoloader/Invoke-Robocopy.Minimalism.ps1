if ($script:publicToExport) {
    $script:publicToExport.function += @(
        'Invoke-Robocopy.Minimalism'
    )
    $script:publicToExport.alias += @(
        'RoboCopy📁'
        'RoboCopy▸'
        'Robo.Copy▸'
        'Robo.Copy'
        'Robo.Copy.Mini'

        # 'RoboCopy Copy'  <# and #> 'RoboCopy Copy'
        # 'Robo.Copy'      <# and #> 'Robo.Mirror'

        # # $NativeCmd▸$SubCommand
        # 'Robo▸ -help'
        # 'Robo▸Copy'       <# and #> 'Robo▸Mirror'
        # 'Robo▸Copy' -Help <# and #> 'Robo▸Mirror' -help

        # #
        # 'Robo⁞Copy'  'Robo🗄'      'RoboCopy'
        # 'RoboCopy▸'  'RoboCopy📁'  'RoboCopy🗄'


        # $ai ??= @{}
        # ( $ai.1 ??= ai 'stuff' && (ToastIt -Title 'Ai' -Text 'step1' ) )
        # ( $ai.2 ??= ai '# stuff'  && (ToastIt -Title 'Ai' -Text 'step2' )  )

        # 'Robo.Copy.Minimal', # 'Invoke-Robocopy.Minimalism'
        # 'Robo.minimal', # 'Invoke-Robocopy.Minimalism'
        # 'Robo⁞Copy', # 'Invoke-Robocopy.Minimalism'
        # # 'Robo⇢⁞ ┐⇽▂Copy📁', # 'Invoke-Robocopy.Minimalism'
        # 'Robo▸Copy', # 'Invoke-Robocopy.Minimalism'
        # 'RoboCopy▸', # 'Invoke-Robocopy.Minimalism'
        # # 'Robo🗄', # 'Invoke-Robocopy.Minimalism'
        # 'RoboCopy📁' # 'Invoke-Robocopy.Minimalism'
        # # 'Invoke-Robocopy.Minimalism'
    )
}

$RoboAppConf ??= @{
    Root = $PSScriptRoot | Get-Item
    Log  = @{
        # Path = Join-Path $PSSCriptRoot 'robo.last.log'
        Path = Join-Path 'G:\temp\logs' 'robo▸Minimalism.last.log'
    }
}
& { # remove me
    try { 
        'Robo▸log size: {0:n2} kb, path: "{0}"' -f @( 
    (gi $RoboAppConf.Log.Path -ea 'ignore').Length / 1kb
    (gi $RoboAppConf.Log.Path -ea 'ignore').FullName
        ) | Write-Verbose
    }
    catch { 
        Write-Warning 'add an actual logger'
    }
}
# $RoboPaths = $Null # always new, for now.
# $RoboPaths ??= Get-Content (Get-Item -ea stop (Join-Path $PSScriptRoot 'paths_saved.json'  )) | ConvertFrom-Json

# 'see: $RoboPaths'
# $RoboPaths | Format-Table -AutoSize
# $RoboAppConf | Format-Table -AutoSize

# paths were from the external test, not really used, or will be stripped out
<#
try { 
    $RoboPaths ??= Get-Content (Get-Item -ea 'silentlycontinue' (Join-Path $RoboAppConf.Root 'paths_saved.json'  )) | ConvertFrom-Json
    try {
        $RoboPaths.GetEnumerator() | ForEach-Object {
            if ($null -eq $_.key) { return }
            @{ $_.Key = ($_.Value)?.ToString() ?? '<null>' }
        }
        | to->Json -Compress | ForEach-Object { $_ -replace '},{', "},`n{" } | sc 'saved_paths2.json' -PassThru
    }
    catch {
        'auto-text-format-had-error'
        '📚 enter ==> other ==>  H:\media\pdf\2023\tosort\init_robocopy_args.ps1/008d1ccc-23cc-4bd1-8a15-15f7fb248a0f' | Write-Warning
        $_
    }
} catch {
    'roboCopy.minimalism: -not $RoboPaths. ' | Write-Warning
}
#>

function Invoke-Robocopy.Minimalism {
    # [EnsureNativeCommand('robocopy')]
    # [EnsureFileExists( $RoboAppConf.Log.Path )]
    <#
    .SYNOPSIS
        zerodepend: this is for a minimalism wrapper vs the main robocopy wrapper
    .DESCRIPTION
            Meant to very quickly start a robocopy from the command line without config
            without any args
    .EXAMPLE

        $From = 'D:\backup\2018\art'
        $to = 'H:\data\art'
        robo.spartan.copy -SourcePath $From -DestPath $to -WhatIf
    .EXAMPLE
        # a test run,  using -RoboWhatIf
        # which means run robocopy '/L'

        $From = 'D:\backup\2018\art'
        $to = 'H:\data\art'
        robo.spartan.copy -SourcePath $From -DestPath $to -RoboWhatIf
    #>
    [Alias(
        # todo: re-evaluate these aliases after fixing tabexpansion: autocompleter to evaluate which complete cleaner
        'RoboCopy▸',        
        'Robo.Copy',
        'Robo.Copy.Mini',

        # 'Robo.Copy.Mini',
        # 'Robo.Copy',
        # 'Robo.Copy▸',
        # 'Robo.minimal',
        # 'Robo⁞Copy',
        # 'Robo▸Copy',        
        # 'RoboCopy▸',
        # 'Robo⇢⁞ ┐⇽▂Copy📁',
        # 'Robo🗄',
        'RoboCopy📁'
        # 'RoboCopy🗄'
        # 'Robo⇢⁞ ┐⇽▂Copy📁',
        # 'Robo▸·⇢⁞ ┐⇽▂Copy📁',
    )]
    [CmdletBinding()]
    param(
        # folder to save
        [Parameter(Mandatory, Position = 0)]
        [string]$SourcePath,

        # folder destination
        [Parameter(Mandatory, Position = 1)]
        [string]$DestPath,

        # view command args, and also '/L' for robocopy
        # robocopy specific whatif, the '/L'
        [Alias('TestRun')]
        [switch]$RoboWhatIf,
        # regular
        [switch]$WhatIf,
        [switch]$Silent,

        # as a switch
        [Alias('NoETA')][switch]$WithoutETA,

        [string[]]$NotUsing = @(),

        # experiment parameters, arbitrary properties, without Kwargs
        # future: even better, custom attribute suggets values using the argument completer
        # then autocomplete like "-x +ETA +RoboWhatIf -debug -color"
        [Alias(
            # '+',
            # 'opt+', # wonder if this parses on bind
            'On'
            # 'Using',
            # todo: re-evaluate these aliases after fixing tabexpansion: autocompleter to evaluate which complete cleaner
            # 'Include',
            # 'IncludeConfig'
            # 'IncludeOptions'
        )]
        [string[]]$IncludeConfig = @(),
        [Alias(
            # todo: re-evaluate these aliases after fixing tabexpansion: autocompleter to evaluate which complete cleaner
            # '-', # wonder if this parses on bind
            # 'opt-', # this parses easier

            'Off'
            # 'Using',
            # 'Exclude',
            # 'Exclude',
            # 'ExcludeOptions'
        )]
        [string[]]$ExcludeConfig = @(),



        [hashtable]$Options
    )

    if ($Silent) { throw 'NYI param' }
    if($IncludeConfig -or $ExcludeConfig) { throw 'param NYI' }
    $binRobo = Get-Command 'RoboCopy' -CommandType Application -ea stop
    New-Item -Path $RoboAppConf.Log.Path -ItemType File -ea ignore # [EnsureFileExists( $RoboAppConf.Log.Path )]

    if (-not(Test-Path $DestPath)) {
        'Path does not exist, create it? "{0}"' -f @( $DestPath )
        mkdir -Path $DestPath -Confirm -Verbose
    }


    [Collections.Generic.List[Object]]$RoboArgs = @(
        (Get-Item -ea stop $SourcePath )
        (Get-Item -ea stop $DestPath )
        '/S'
        '/COPY:DAT'
        '/UNICODE'
        '/UNILOG:{0}' -f @( $RoboAppConf.Log.Path | Get-Item -ea stop )
        #    '/UNILOG:lastBig.basic.log' -f @( )
        '/tee'
        if ($RoboWhatIf) { '/L' }
        if ( -not $WithoutETA) { '/ETA' }
    )
    $renderRoboArgs = $RoboArgs | Join-String -sep ' ' -op 'robocopy.exe args: '

    $renderRoboArgs | Write-Information
    $renderRoboArgs | Write-Verbose

    if ($WhatIf) {
        $renderRoboArgs
        # & RoboCopy @RoboArgs
        return
    }
    if ($PSCmdlet.ShouldProcess('CopyFiles', 'RoboCopy')) {
        & RoboCopy @RoboArgs
    }

}

@'
see also:
    - <file:///H:\root_T_oldClone\Usage%20of%20invoke-robocopy-best.iter3.ps1>
try:
    robo.spartan.copy -Whatif -SourcePath '/foo/bar' -DestPath $RoboPaths.'2016Media'
'@ | Out-Null