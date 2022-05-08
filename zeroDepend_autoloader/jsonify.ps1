


function JsoNinfy {
    <#
    .SYNOPSIS
        minimal hack to process objects before default handler is called
    .DESCRIPTION
        converts specific types to specific outputs

    #>
    param(
        [parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )

    process {
        switch ($InputObject) {
            { $_ -is [PoshCode.Pansies.RgbColor] } {
                @{
                    NinTypeName = 'RgbColor'
                    RGB         = '#{0}' -f @($_.Rgb)
                }
            }
            { $_ -is [System.IO.FileSystemInfo] } {
                # return $InputObject
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


function UnJsoNinfy {
    <#
    .SYNOPSIS
        minimal hack to process objects before default handler is called
    .DESCRIPTION
        converts specific types to specific outputs

    #>
    param(
        [parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )

    process {
        switch ($InputObject) {

            # 'NinTypeName' = 'RGBColor'
            # IO.FileSystemInfo
            # NinTypeName
            { $_ -is [RgbColor] } {
                '#{0}' -f @($_.Rgb)
            }
            { $_ -is [System.IO.FileSystemInfo] } {
                # return $InputObject
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
$sample = @( 2342354, 'sdfs', (Get-Item .), 'foo' )

H1 'none'
$sample | to->Json


H1 'files'
$sample | JsoNinfy | to->Json

H1 'none'
[rgbcolor]'red' | to->Json


H1 'files'
@(
    Get-Item .
    [rgbcolor]'red'
) | JsoNinfy | to->Json
