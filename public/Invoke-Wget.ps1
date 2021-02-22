function Invoke-Wget {
    <#
    .SYNOPSIS
    Wrapper with defaults nice on bandwidth, and output

    .DESCRIPTION
        recursive Wget
        based on defaults from:
            - <https://gist.github.com/stvhwrd/985dedbe1d3329e68d70#1st-way>
            - <https://simpleit.rocks/linux/how-to-download-a-website-with-wget-the-right-way/>

    see also:

        --level=NUMBER
            max depth
        --timestamping
        --backups=N
        --background
            don't print progress
        --save-headers
        --no-parent
        --wait=2
        --no-clobber
        -e robots=off
            turn off the robot exclusion

    .EXAMPLE
        # Adding extra arguments, ex: '--wait=2 --background'
        PS> Invoke-Wget -Uri 'https://<some-url-with-cats>.com' -Path 'c:\export\cats' -Args '--wait=2', '--background'

    .EXAMPLE
        PS> Invoke-Wget -Uri 'https://<some-url-with-cats>.com' -Path 'c:\export\cats'
        PS> Invoke-Wget -Uri 'https://flask-wtf.readthedocs.io/en/stable' -Path 'stuff' -WhatIf -Verbose -args '--wait=2', '--background'
    .EXAMPLE
        # Check which args are passed to wget
        PS> Invoke-Wget -Uri 'https://<some-url-with-cats>.com' -Path 'c:\export\cats' -Verbose

        VERBOSE: wget args: --limit-rate=200k --no-clobber --convert-links --random-wait --recursive --page-requisites --adjust-extension -e robots=off --user-agent=mozilla https://<some-url-with-cats>.com -P 'c:\export\cats'

        What if: Performing the operation "wget: https://<some-url-with-cats>.com" on target "c:\export\cats".


    .NOTES
    General notes
    #>
    [cmdletbinding(SupportsShouldProcess)]
    param(
        # Docstring
        [Parameter(Mandatory, Position = 0)]
        [System.Uri]$Uri,

        # Path: Root of export path
        [Parameter(Mandatory, Position = 1)]
        [string]$Path = '.',

        # Rest
        [Alias('Args')]
        [Parameter(ValueFromRemainingArguments, Position = 2)]
        [string[]]$RemainingArgs
    )

    [string[]]$wget_args = @(
        '--limit-rate=200k' # 20k
        '--no-clobber'
        '--convert-links'
        '--random-wait'
        '--recursive'           # '-r'
        '--page-requisites'     # '-p'
        '--adjust-extension'    # '-E'
        '-e'
        'robots=off'
        '--user-agent=mozilla' # '-U', 'mozilla'
        $uri
        '-P'
        $Path
    )
    $wget_args += $RemainingArgs

    'wget args: ' + ($wget_args -join ' ') | Write-Verbose

    # if ($PSCmdlet.ShouldProcess($uri, "wget: $Path")) {
    if ($PSCmdlet.ShouldProcess($Path, "wget: $uri")) {
        Invoke-NativeCommand 'wget' -ArgumentList $wget_args
    }
}

