#Requires -Version 7

if ( $publicToExport ) {
    $publicToExport.function += @(
        'ConvertFrom-Jsonify'
        'ConvertTo-Jsonify'
    )
    $publicToExport.alias += @(
        'unJsonify' # ConvertFrom-Jsonify
        'Jsonify' # ConvertTo-Jsonify
        'to->JsonNin'
        'from->JsonNin'
    )
}


function ConvertTo-Jsonify {
    <#
    .SYNOPSIS
        minimal hack to process objects before default handler is called
    .DESCRIPTION
        converts specific types to specific outputs
    .notes
        dependencies:
            directly: none
            Indirectly: RgbColor, and handling of types
        to test:
            - [ ] get-process
            - [ ] gci Env:
    .example
        PS> # Round trip:
            ls .| Jsonify | to->Json
                | from->Json | unJsonify

    .link
        Ninmonkey.Console\ConvertTo-Jsonify
    .link
        Ninmonkey.Console\ConvertFrom-Jsonify
    #>
    [Alias(
        'Jsonify',
        'to->JsonNin'

    )]
    param(
        [parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )

    process {
        <#
        types to add:
            - [Diagnostics.Process]
            -
        #>
        switch ($InputObject) {
            { $_ -is [PoshCode.Pansies.RgbColor] } {
                @{
                    NinTypeName = 'RgbColor'
                    RGB         = '{0}' -f @($_.Rgb)
                }
            }
            { $_ -is [System.IO.FileSystemInfo] } {
                # Some stats only make sense to travel one direction (write time, size)
                # This allows optional properties for human readability
                @{
                    NinTypeName   = 'IO.FileSystemInfo'
                    Path          = $InputObject.FullName -replace '\\', '/'
                    EnvPath       = $InputObject | ConvertTo-EnvVarPath
                    Bytes         = $InputObject.Length
                    LastWriteTime = $InputObject.LastWriteTime
                }

            }
            default {
                $InputObject

            }
        }
    }
}


function ConvertFrom-Jsonify {
    <#
    .SYNOPSIS
        minimal hack to process objects before default handler is called
    .DESCRIPTION
        converts specific types from 'Jsonify' to objects
    .link
        Ninmonkey.Console\ConvertTo-Jsonify
    .link
        Ninmonkey.Console\ConvertFrom-Jsonify
    #>
    [Alias(
        'unJsonify',
        'from->JsonNin'
    )]
    param(
        [parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )

    process {
        Write-Debug 'jsonify: DeSerialize -> enter'
        if ($Null -eq $InputObject) {
            Write-Debug 'jsonify: Object == $Null'
            return $null # if not, mutates source
        }
        if (! $InputObject.NinTypeName ) {
            Write-Debug 'jsonify: No property NinTypeName'
            return $InputObject
        }
        $InputObject.NinTypeName | Write-Debug
        switch ($InputObject.NinTypeName) {
            'RgbColor' {
                $rgb = $InputObject.RGB -as 'int'
                $obj = [rgbcolor]::FromRgb( $rgb )
                return $obj
            }

            'IO.FileSystemInfo' {
                # future: resolve->fileinfo if not yet existing
                # file info seems to work for both files and fodlers
                $obj = Get-Item $InputObject.Path -ea ignore
                if (! $obj ) {
                    $Obj = [System.IO.FileInfo]::new( $InputObject.Path)
                }
                return $obj

            }
            default {
                "UnhandledNinTypeObject: Object has property NinTypeName, but fell through call conditions: $($InputObject.GetType())"
                | Write-Warning

                return $InputObject
            }
        }
    }
}
