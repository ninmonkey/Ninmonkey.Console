function Get-NinNewestItem {
    <#
    .synopsis
        Quickly find preset file types in directories
    .description
        .
    .example
        PS>
    .notes
        .
    #>
    param (
        [Parameter(
            Mandatory, Position = 0,
            HelpMessage = 'Item Type')]
        # todo: refactor using a config file
        [ValidateSet(
            'VS Code | Project',
            'VS Code | Folder',
            'Power BI',
            'Powershell',
            'All'
        )]
        [string[]]$ItemType = 'All',

        [Parameter(
            # Mandatory,
            Position = 1,
            HelpMessage = 'Saved Locations')]
        [ValidateSet(
            '2020',
            '2020 ⇾ Powershell',
            '2020 ⇾ Power BI',
            '2020 ⇾ Ninmonkeys.com',
            'Powershell ⇾ MyModules_Github',
            'Github Downloads'
        )]
        [string[]]$Location,

        [Parameter(

            HelpMessage = 'Optionally specify sort property')]
        [ValidateSet('LastWriteTime', 'LastAccessTime')]
        [string]$SortProperty
    )

    # if ($Location.count -eq 0) {
    #     $BasePaths = Get-Item .
    # }
    # $BasePaths = $Location | Where-Object {
    #     [string]::IsNullOrWhiteSpace($_)
    # } | Where-Object Test-Path | Get-Item
    $BasePaths = $Location | Where-Object Test-Path | Get-Item
    if ($BasePaths.count -eq 0) {
        $BasePaths = Get-Item '.'
    }

    # $BasePaths | Join-String -OutputPrefix 'paths: ' -Separator ', ' -Property { '..', $_.Name -join '' }
    $splat_JoinString = @{
        OutputPrefix = 'paths: '
        Separator    = ', '
        # Property     = { '..', $_.Name -join '' }
        Property     = {
            $_.FullName | Resolve-Path -Relative
        }
    }
    $BasePaths | Join-String @splat_JoinString | Write-Debug

    $splat_JoinString['Property'] = {
        $_
    }
    $splat_JoinString['OutputPrefix'] = 'items: '

    $ItemType | Join-String @splat_JoinString | Write-Debug

    $splatLs = @{
        Path    = $BasePaths
        Filter  = '*.x'
        Recurse = $true
        Force   = $true
    }

    $sortSplat = @{
        Descending = $true
        Property   = $SortProperty
    }
    $resultList = [list[psobject]]::new()

    switch ($ItemType) {
        'VS Code | Project' {
            Get-ChildItem @lsSplat
            | ForEach-Object { $resultList.Add( $_ ) }
            continue

        }
        'VS Code | Folder' {
            'folder'
            continue
        }
        'Power BI' {
            continue
        }
        'Powershell' {
            continue
        }
        'All' {
            continue
        }
        default {
            throw "ShouldNeverReach: '$ItemType'"
            break
        }
    }

    ## only if not empty | Sort-Object @sortSplat
    $resultList


}

Get-NinNewestItem -Verbose -Debug -ItemType 'VS Code | Project', 'Powershell'
hr
Get-NinNewestItem -Verbose -Debug -ItemType 'VS Code | Folder', 'VS Code | Project'
