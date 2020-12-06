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
        # Item type?
        # todo: refactor using a config file
        [Parameter(Mandatory, Position = 0)]
        [ValidateSet(
            'VS Code | Project',
            'VS Code | Folder',
            'Power BI',
            'Powershell',
            'All'
        )]
        [string[]]$ItemType = 'All',

        # saved locations
        [Parameter(Position = 1)]
        [ValidateSet(
            '2020',
            '2020 ⇾ Powershell',
            '2020 ⇾ Power BI',
            '2020 ⇾ Ninmonkeys.com',
            'Powershell ⇾ MyModules_Github',
            'Github Downloads'
        )]
        [string[]]$Location,

        # optional property name to sort by
        [Parameter()]
        [ValidateSet('LastWriteTime', 'LastAccessTime')]
        [string]$SortProperty
    )

    # if ($Location.count -eq 0) {
    #     $BasePaths = Get-Item .
    # }
    # $BasePaths = $Location | Where-Object {
    #     [string]::IsNullOrWhiteSpace($_)
    # } | Where-Object Test-Path | Get-Item
    $mappedPaths = @{
        '2020'                          = "$Env:UserProfile\Documents\2020"
        '2020 ⇾ Powershell'             = "$Env:UserProfile\Documents\2020\Powershell"
        '2020 ⇾ Power BI'               = "$Env:UserProfile\Documents\2020\Power BI"
        '2020 ⇾ Ninmonkeys.com'         = "$Env:UserProfile\Documents\ninmonkeys.com ┐ main"
        'Powershell ⇾ MyModules_Github' = "$Env:UserProfile\Documents\2020\Powershell\MyModules_Github"
        'Github Downloads'              = 'G:\2020-github-downloads'
    }

    $MappedList = $Location | ForEach-Object {
        if ($mappedPaths.Contains($_)) {
            $mappedPaths[$_]
        }
    }
    $MappedList | Join-String -sep ', ' -OutputPrefix 'Mapped Paths: ' | Write-Debug


    $BasePaths = $MappedLocation | Where-Object Test-Path | Get-Item
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
        Filter  = ''
        Recurse = $true
        Force   = $true
    }

    $sortSplat = @{
        Descending = $true
        Property   = $SortProperty
    }
    $resultList = [list[psobject]]::new()

    $resultList = foreach ($CurItemType in $ItemType) {
        switch ($CurItemType) {
            'VS Code | Project' {
                # h1 'yes'
                $itemArgs = @{
                    Filter    = '*.code-workspace'
                    File      = $true
                    Directory = $false
                }
                # $splat = $splatLs + $itemArgs
                $splat = Join-Hashtable $splatLs $itemArgs
                $splat | Format-Table -Wrap | Out-String | Write-Debug
                Get-ChildItem @splat
                # | ForEach-Object { $resultList.Add( $_ ) }
                break

            }
            'VS Code | Folder' {
                break
            }
            'Power BI' {
                break
            }
            'Powershell' {
                break
            }
            'All' {
                break
            }
            default {
                throw "ShouldNeverReach: '$ItemType'"
                break
            }
        }
    }

    ## only if not empty | Sort-Object @sortSplat
    hr
    H1 "Count: $($resultList.Count)"
    $resultList

    Write-Warning "command is a WIP"


}

# # Import-Module Ninmonkey.Powershell -Force # might be needed to prevent getting overwritten by that psutil Join-hashtable
# if ($false) {
#     Get-NinNewestItem -Verbose -Debug -ItemType 'VS Code | Project', 'Powershell'
#     hr
#     Get-NinNewestItem -Verbose -Debug -ItemType 'VS Code | Folder', 'VS Code | Project' -ov lastNew
# }

# $getNinNewestItemSplat = @{
#     SortProperty = 'LastWriteTime'
#     ItemType     = 'VS Code | Project'
#     # Location     = '2020 ⇾ Powershell'
#     Location     = '2020 ⇾ Powershell', 'Github Downloads'
#     Debug        = $true
#     Verbose      = $true
# }

# Get-NinNewestItem @getNinNewestItemSplat -OutVariable LastNew